import { Line } from '@ant-design/charts';

export default function AcademicPerformanceChart({ history }) {
  // Transform history data for the chart
  const chartData = [];
  
  if (history && history.length > 0) {
    history.forEach(semester => {
      if (semester.gpa10 != null) {
        chartData.push({
          semester: semester.tenKi,
          value: semester.gpa10,
          type: 'GPA hệ 10'
        });
      }
      if (semester.gpa4 != null) {
        chartData.push({
          semester: semester.tenKi,
          value: semester.gpa4,
          type: 'GPA hệ 4'
        });
      }
    });
  }

  const config = {
    data: chartData,
    xField: 'semester',
    yField: 'value',
    seriesField: 'type',
    yAxis: {
      label: {
        formatter: (v) => Number(v).toFixed(1)
      }
    },
    legend: {
      position: 'top-right'
    },
    smooth: true,
    animation: {
      appear: {
        animation: 'path-in',
        duration: 1000
      }
    },
    color: ['#1677ff', '#52c41a'], // Blue for GPA 10, Green for GPA 4
    point: {
      size: 4,
      shape: 'circle'
    },
    tooltip: {
      formatter: (datum) => {
        return {
          name: datum.type,
          value: datum.value.toFixed(2)
        };
      }
    }
  };

  // If no data, show empty state
  if (chartData.length === 0) {
    return (
      <div style={{
        background: '#fff',
        border: '1px solid var(--color-border)',
        borderRadius: 6,
        padding: 20,
        height: 280,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        color: '#999',
        fontSize: 14
      }}>
        Chưa có dữ liệu GPA để hiển thị biểu đồ
      </div>
    );
  }

  return (
    <div style={{
      background: '#fff',
      border: '1px solid var(--color-border)',
      borderRadius: 6,
      padding: 20
    }}>
      <div style={{
        fontSize: 14,
        fontWeight: 600,
        marginBottom: 16,
        fontFamily: 'var(--font-display)',
        color: '#1f1f1f'
      }}>
        Biểu đồ học tập
      </div>
      <Line {...config} height={280} />
    </div>
  );
}
