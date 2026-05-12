import { Tooltip } from 'antd';
import s from '../styles.module.css';

export default function ScheduleCell({ items, conflict }) {
  if (items.length === 0) return <div className={s.cell + ' ' + s.empty} />;
  const cls = s.cell + ' ' + (conflict ? s.cellConflict : s.cellFilled);
  return (
    <Tooltip title={items.map(i => `${i.lhp.monHocTen} — ${i.b.phong}`).join('\n')}>
      <div className={cls}>{items[0].lhp.monHocTen.slice(0, 8)}</div>
    </Tooltip>
  );
}
