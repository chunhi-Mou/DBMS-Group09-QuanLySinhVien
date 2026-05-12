package com.qlsv.seed;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.*;

@Slf4j
@Component
@Profile("seed")
@RequiredArgsConstructor
public class DataSeeder implements CommandLineRunner {

    private final JdbcTemplate jdbc;
    private final ObjectMapper mapper = new ObjectMapper();
    private final BCryptPasswordEncoder bcrypt = new BCryptPasswordEncoder();

    @Value("${qlsv.seed.dir}")
    private String seedDir;

    @Override
    @Transactional
    public void run(String... args) throws Exception {
        log.info("Seeding from {}", seedDir);
        for (var item : SeedFileMap.ORDER) {
            seed(item.table(), item.file());
        }
        log.info("Seeding done.");
    }

    private void seed(String table, String file) throws Exception {
        Path p = Path.of(seedDir, file);
        if (!Files.exists(p)) { log.warn("Skip {} — not found", p); return; }

        long existing = jdbc.queryForObject("SELECT COUNT(*) FROM `" + table + "`", Long.class);
        if (existing > 0) { log.info("Skip {} — already has {} rows", table, existing); return; }

        JsonNode root = mapper.readTree(Files.readString(p));
        if (!root.isArray() || root.size() == 0) return;

        List<String> cols = new ArrayList<>();
        root.get(0).fieldNames().forEachRemaining(cols::add);

        String colSql  = String.join(",", cols.stream().map(c -> "`" + c + "`").toList());
        String placeSql = String.join(",", cols.stream().map(c -> "?").toList());
        String sql = "INSERT INTO `" + table + "` (" + colSql + ") VALUES (" + placeSql + ")";

        for (JsonNode row : root) {
            Object[] vals = new Object[cols.size()];
            for (int i = 0; i < cols.size(); i++) {
                JsonNode v = row.get(cols.get(i));
                vals[i] = toJdbc(table, cols.get(i), v);
            }
            jdbc.update(sql, vals);
        }
        log.info("Seeded {} rows into {}", root.size(), table);
    }

    private Object toJdbc(String table, String col, JsonNode v) {
        if (v == null || v.isNull()) return null;
        // Hash password ThanhVien if plaintext
        if ("ThanhVien".equals(table) && "password".equals(col) && v.isTextual()) {
            String s = v.asText();
            return s.startsWith("$2") ? s : bcrypt.encode(s);
        }
        if (v.isInt() || v.isLong()) return v.asLong();
        if (v.isDouble() || v.isFloat()) return v.asDouble();
        if (v.isBoolean()) return v.asBoolean();
        return v.asText();
    }
}
