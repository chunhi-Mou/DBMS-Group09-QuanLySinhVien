import { useEffect, useState, useRef } from 'react';
import { Card, Row, Col, Spin, Select, Tooltip } from 'antd';
import { Pie, Bar, Line, Column } from '@ant-design/charts';
import { Users, GraduationCap, BookOpen, Layers, TrendingUp, TrendingDown, BarChart3, Building } from 'lucide-react';
import { adminApi } from '../../../api/endpoints/admin';

function trunc(text, max = 16) {
  if (!text) return '';
  return text.length > max ? text.slice(0, max) + '…' : text;
}

const CHART_CARD = {
  borderRadius: 10,
  overflow: 'hidden',
  boxShadow: '0 2px 8px rgba(0,0,0,0.06)',
};

/* Animated counter hook */
function useCounter(target, duration = 900) {
  const [val, setVal] = useState(0);
  const ref = useRef();
  useEffect(() => {
    if (target == null) return;
    const t = Number(target);
    if (!t) { setVal(0); return; }
    let start = null;
    const step = (ts) => {
      if (!start) start = ts;
      const p = Math.min((ts - start) / duration, 1);
      setVal(Math.round(p * t));
      if (p < 1) ref.current = requestAnimationFrame(step);
    };
    ref.current = requestAnimationFrame(step);
    return () => cancelAnimationFrame(ref.current);
  }, [target, duration]);
  return val;
}

function StatCard({ title, value, icon, color, delay }) {
  const count = useCounter(value);
  return (
    <div style={{ animation: `fadeIn 400ms ease-out ${delay}ms both` }}>
      <Card
        size="small"
        hoverable
        style={{
          borderLeft: `3px solid ${color}`,
          borderRadius: 10,
          cursor: 'default',
        }}
        styles={{ body: { padding: '12px 16px' } }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
          <div style={{
            width: 40, height: 40, borderRadius: 10,
            background: `${color}14`, display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <span style={{ color }}>{icon}</span>
          </div>
          <div>
            <div style={{ fontSize: 12, fontWeight: 600, color: '#666', lineHeight: 1.2 }}>{title}</div>
            <div style={{ fontSize: 26, fontWeight: 700, color: '#1f1f1f', lineHeight: 1.3 }}>{count}</div>
          </div>
        </div>
      </Card>
    </div>
  );
}

/* ── Shared label styles — BOLD, READABLE ── */
const AXIS_LABEL = {
  labelFontSize: 13,
  labelFontWeight: 600,
  labelFill: '#333',
};
const AXIS_LABEL_SM = {
  labelFontSize: 12,
  labelFontWeight: 600,
  labelFill: '#444',
};
const AXIS_TICK = {
  labelFontSize: 12,
  labelFontWeight: 500,
  labelFill: '#555',
};

export default function AdminDashboard() {
  const [data, setData] = useState(null);
  const [selectedKi, setSelectedKi] = useState(null);
  const [hocLucData, setHocLucData] = useState(null);
  const [hocLucLoading, setHocLucLoading] = useState(false);

  useEffect(() => { adminApi.adminDashboard().then(setData); }, []);

  useEffect(() => {
    if (!data) return;
    const kiId = selectedKi ?? data.kiHocHienTaiId;
    if (!kiId) return;
    setHocLucLoading(true);
    adminApi.reportHocLuc(kiId).then(res => {
      setHocLucData(res.phanBo?.map(d => ({ type: d.loaiHocLuc ?? 'Chưa xếp', value: Number(d.soLuong) })) || []);
      setHocLucLoading(false);
    }).catch(() => setHocLucLoading(false));
  }, [data, selectedKi]);

  if (!data) return <Spin style={{ display: 'block', margin: '120px auto' }} />;

  const kiOptions = (data.kiHocList || []).map(k => ({ value: k.id, label: k.ten }));

  const stats = [
    { title: 'Sinh viên', value: data.tongSv, icon: <Users size={20} />, color: '#1677ff' },
    { title: 'Giảng viên', value: data.tongGv, icon: <GraduationCap size={20} />, color: '#52c41a' },
    { title: 'Lớp học phần', value: data.tongLhp, icon: <Layers size={20} />, color: '#722ed1' },
    { title: 'Môn học', value: data.tongMon, icon: <BookOpen size={20} />, color: '#fa8c16' },
  ];

  const khoaData = data.svTheoKhoa.map(k => ({ khoa: k.khoa, count: Number(k.count) }));
  const truotData = (data.topMonTruot || []).map(d => ({
    monHoc: d.monHoc ?? '',
    tyLeTruot: typeof d.tyLeTruot === 'number' ? d.tyLeTruot : 0,
  }));
  const gpaData = (data.gpaQuaKi || []).map(d => ({ kiHocTen: d.kiHocTen ?? '', gpa: d.gpa ?? 0 }));

  const hocLucColors = ['#52c41a', '#13c2c2', '#1677ff', '#faad14', '#f5222d', '#722ed1'];

  return (
    <div className="fade-in">
      {/* Stats row — compact, with stagger */}
      <Row gutter={[12, 12]} style={{ marginBottom: 14 }}>
        {stats.map((s, i) => (
          <Col xs={12} sm={6} key={s.title}>
            <StatCard {...s} delay={i * 80} />
          </Col>
        ))}
      </Row>

      {/* Charts row 1 */}
      <Row gutter={[12, 12]} style={{ marginBottom: 12 }}>
        <Col xs={24} lg={12}>
          <div style={{ animation: 'fadeIn 500ms ease-out 350ms both' }}>
            <Card size="small" style={CHART_CARD}
              title={<span style={{ fontWeight: 600, fontSize: 14 }}><BarChart3 size={14} style={{ marginRight: 6, verticalAlign: -2 }} />Phân bổ học lực</span>}
              extra={<Select size="small" value={selectedKi ?? data.kiHocHienTaiId} onChange={setSelectedKi} options={kiOptions} style={{ width: 180 }} />}>
              {hocLucLoading ? <Spin /> :
                (!hocLucData || hocLucData.length === 0)
                  ? <em style={{ color: '#999' }}>Chưa có dữ liệu.</em>
                  : <Pie data={hocLucData} angleField="value" colorField="type" radius={0.78} innerRadius={0.52}
                      height={220}
                      scale={{ color: { range: hocLucColors } }}
                      interaction={{ tooltip: true }}
                      label={{
                        text: (d) => {
                          const total = hocLucData.reduce((s, x) => s + x.value, 0);
                          const pct = total ? ((d.value / total) * 100).toFixed(1) : 0;
                          return `${d.type}\n${pct}%`;
                        },
                        position: 'outside',
                        fontSize: 13, fontWeight: 600, fill: '#222',
                        connector: true,
                      }}
                      legend={{ color: { position: 'bottom', layout: { justifyContent: 'center' }, itemLabelFontSize: 13, itemLabelFontWeight: 600, itemLabelFill: '#333' } }}
                      animate={{ enter: { type: 'waveIn', duration: 800 } }} />
              }
            </Card>
          </div>
        </Col>
        <Col xs={24} lg={12}>
          <div style={{ animation: 'fadeIn 500ms ease-out 450ms both' }}>
            <Card title={<span style={{ fontWeight: 600, fontSize: 14 }}><Building size={14} style={{ marginRight: 6, verticalAlign: -2 }} />Sinh viên theo Khoa</span>} size="small" style={CHART_CARD}>
              <Bar data={khoaData} xField="count" yField="khoa"
                colorField="khoa"
                height={220}
                scale={{ color: { range: ['#1677ff', '#13c2c2', '#722ed1', '#eb2f96', '#faad14', '#52c41a'] } }}
                axis={{
                  y: {
                    labelFormatter: (t) => trunc(t, 18),
                    style: { ...AXIS_LABEL }
                  },
                  x: {
                    style: { ...AXIS_TICK }
                  }
                }}
                label={{ text: 'count', position: 'right', fontSize: 14, fontWeight: 700, fill: '#222' }}
                legend={false}
                style={{ radiusTopRight: 4, radiusBottomRight: 4 }}
                animate={{ enter: { type: 'growInX', duration: 700 } }} />
            </Card>
          </div>
        </Col>
      </Row>

      {/* Charts row 2 */}
      <Row gutter={[12, 12]}>
        <Col xs={24} lg={12}>
          <div style={{ animation: 'fadeIn 500ms ease-out 550ms both' }}>
            <Card title={<span style={{ fontWeight: 600, fontSize: 14 }}><TrendingUp size={14} style={{ marginRight: 6, verticalAlign: -2 }} />GPA trung bình qua các kỳ</span>} size="small" style={CHART_CARD}>
              <Line data={gpaData} xField="kiHocTen" yField="gpa"
                height={220}
                style={{ stroke: '#1677ff', lineWidth: 2.5 }}
                point={{ shapeField: 'point', sizeField: 5 }}
                axis={{
                  x: {
                    labelFormatter: (t) => trunc(t, 12),
                    style: { ...AXIS_LABEL_SM, labelTransform: 'rotate(-30)' },
                  },
                  y: {
                    labelFormatter: (v) => Number(v).toFixed(1),
                    style: { ...AXIS_TICK }
                  },
                }}
                tooltip={{ items: [{ channel: 'y', name: 'GPA', valueFormatter: (v) => Number(v).toFixed(2) }] }}
                animate={{ enter: { type: 'pathIn', duration: 800 } }} />
            </Card>
          </div>
        </Col>
        <Col xs={24} lg={12}>
          <div style={{ animation: 'fadeIn 500ms ease-out 650ms both' }}>
            <Card title={<span style={{ fontWeight: 600, fontSize: 14 }}><TrendingDown size={14} style={{ marginRight: 6, verticalAlign: -2, color: '#cf1322' }} />Top 10 môn tỉ lệ trượt cao nhất</span>} size="small" style={CHART_CARD}>
              <Column data={truotData} xField="monHoc" yField="tyLeTruot"
                height={220}
                colorField="tyLeTruot"
                scale={{
                  color: {
                    range: ['#fa8c16', '#f5222d'],
                    type: 'linear',
                  }
                }}
                label={{ text: (d) => d.tyLeTruot != null ? d.tyLeTruot.toFixed(1) + '%' : '', position: 'outside', fontSize: 12, fontWeight: 700, fill: '#a8071a' }}
                axis={{
                  x: {
                    labelFormatter: (t) => trunc(t, 10),
                    style: { ...AXIS_LABEL_SM, labelTransform: 'rotate(-35)' },
                  },
                  y: {
                    labelFormatter: (v) => v + '%',
                    style: { ...AXIS_TICK }
                  },
                }}
                tooltip={{ items: [{ channel: 'y', name: 'Tỉ lệ trượt', valueFormatter: (v) => v + '%' }] }}
                animate={{ enter: { type: 'scaleInY', duration: 600 } }} />
            </Card>
          </div>
        </Col>
      </Row>
    </div>
  );
}
