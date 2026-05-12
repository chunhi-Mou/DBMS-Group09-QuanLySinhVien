import { useEffect, useState } from 'react';
import { Spin, Alert, Pagination } from 'antd';
import { studentApi } from '../../../api/endpoints/student';
import { commonApi } from '../../../api/endpoints/common';
import SemesterGradeTable from './SemesterGradeTable';
import EmptyState from '../../../components/EmptyState';

/**
 * BangDiem (Grades Page) - Requirements 15, 16, 17, 18
 * 
 * Displays all semesters in a single scrollable view:
 * - No semester dropdown selector (Requirement 15)
 * - Semesters ordered from most recent to oldest
 * - Pagination if more than 6 semesters
 * - Each semester has a flat table with component grades
 * - Summary block below each semester's grades
 */
export default function BangDiem() {
  const [semesters, setSemesters] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [page, setPage] = useState(1);
  const pageSize = 6;

  useEffect(() => {
    const fetchAllGrades = async () => {
      try {
        setLoading(true);
        setError(null);
        
        // Fetch all semesters
        const kiHocList = await commonApi.kiHocList();
        
        if (!kiHocList || kiHocList.length === 0) {
          setSemesters([]);
          return;
        }

        // Fetch grades for each semester in parallel
        const gradePromises = kiHocList.map(async (ki) => {
          try {
            const gradeData = await studentApi.grades(ki.id);
            if (!gradeData || !gradeData.mon || gradeData.mon.length === 0) {
              return null; // Skip semesters with no grades
            }

            // Transform the data to match SemesterGradeTable props
            const courses = gradeData.mon.map(m => {
              // Build component grades from the nested structure
              const diemThanhPhan = {};
              if (m.diemThanhPhan && Array.isArray(m.diemThanhPhan)) {
                for (const dtp of m.diemThanhPhan) {
                  const ten = (dtp.ten || '').toLowerCase();
                  if (ten.includes('chuyên cần') || ten.includes('chuyen can')) {
                    diemThanhPhan.chuyenCan = { diem: dtp.diem, tile: dtp.tile };
                  } else if (ten.includes('giữa kỳ') || ten.includes('giua ky')) {
                    diemThanhPhan.giuaKy = { diem: dtp.diem, tile: dtp.tile };
                  } else if (ten.includes('cuối kỳ') || ten.includes('cuoi ky') || ten.includes('thi')) {
                    diemThanhPhan.cuoiKy = { diem: dtp.diem, tile: dtp.tile };
                  }
                }
              }

              return {
                monHoc: m.monHoc,
                soTc: m.soTc,
                diemThanhPhan,
                diemTong: m.diemTong,
                heChu: m.heChu,
                diem4: m.diem4,
              };
            });

            // Calculate summary
            const gradedCourses = courses.filter(c => c.diemTong != null);
            const weightedTc = gradedCourses.reduce((s, c) => s + (c.soTc || 0), 0);
            const gpa10 = weightedTc > 0 
              ? gradedCourses.reduce((s, c) => s + c.diemTong * c.soTc, 0) / weightedTc
              : null;
            const gpa4 = weightedTc > 0
              ? gradedCourses.reduce((s, c) => s + (c.diem4 || 0) * c.soTc, 0) / weightedTc
              : null;
            const creditsEarned = gradedCourses
              .filter(c => c.diemTong >= 5)
              .reduce((s, c) => s + (c.soTc || 0), 0);

            return {
              kiHocId: ki.id,
              kiHocTen: ki.ten,
              namHoc: ki.namHoc || '',
              hocKy: ki.hocKy || '',
              courses,
              summary: {
                gpa10,
                gpa4,
                creditsEarned,
                cumulativeCredits: null, // Will be calculated below
              }
            };
          } catch {
            return null; // Skip failed fetches
          }
        });

        const results = (await Promise.all(gradePromises)).filter(Boolean);
        
        // Sort by kiHocId DESC (most recent first)
        results.sort((a, b) => b.kiHocId - a.kiHocId);

        // Calculate cumulative credits
        let cumulative = 0;
        // Process from oldest to newest for cumulative calculation
        const reversed = [...results].reverse();
        for (const sem of reversed) {
          cumulative += sem.summary.creditsEarned || 0;
          sem.summary.cumulativeCredits = cumulative;
        }

        setSemesters(results);
      } catch (e) {
        setError(e?.response?.data?.error?.message || 'Không thể tải bảng điểm');
      } finally {
        setLoading(false);
      }
    };

    fetchAllGrades();
  }, []);

  // Paginate semesters
  const paginatedSemesters = semesters.length > pageSize
    ? semesters.slice((page - 1) * pageSize, page * pageSize)
    : semesters;

  return (
    <div className="fade-in" style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
      {error && <Alert type="error" message={error} showIcon style={{ marginBottom: 2 }} />}

      {/* Page header */}
      <div style={{ 
        background: '#fff', 
        border: '1px solid var(--color-border)', 
        borderRadius: 6, 
        padding: '12px 16px',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between'
      }}>
        <span style={{ fontWeight: 600, fontSize: 16, fontFamily: 'var(--font-display)' }}>
          Bảng điểm toàn bộ
        </span>
        {semesters.length > 0 && (
          <span style={{ color: '#888', fontSize: 13 }}>
            {semesters.length} học kỳ
          </span>
        )}
      </div>

      {loading ? (
        <div style={{ textAlign: 'center', padding: 60 }}><Spin size="large" /></div>
      ) : semesters.length === 0 ? (
        <div style={{ background: '#fff', border: '1px solid var(--color-border)', borderRadius: 6 }}>
          <EmptyState 
            message="Chưa có dữ liệu điểm"
            description="Bảng điểm sẽ hiển thị sau khi kết thúc học kỳ đầu tiên."
          />
        </div>
      ) : (
        <>
          {/* Semester grade tables */}
          <div style={{ display: 'flex', flexDirection: 'column', gap: 24 }}>
            {paginatedSemesters.map(semester => (
              <SemesterGradeTable 
                key={semester.kiHocId}
                semester={semester}
              />
            ))}
          </div>

          {/* Pagination if more than 6 semesters (Requirement 15) */}
          {semesters.length > pageSize && (
            <div style={{ textAlign: 'center', marginTop: 8 }}>
              <Pagination
                current={page}
                pageSize={pageSize}
                total={semesters.length}
                onChange={setPage}
                showSizeChanger={false}
                size="small"
              />
            </div>
          )}
        </>
      )}
    </div>
  );
}
