import { Collapse } from 'antd';
import LhpRow from './LhpRow';

export default function LhpList({ available, selectedIds, allChosen, tickable, conflictsFor, onToggle }) {
  const byMon = new Map();
  for (const lhp of (available.lopHocPhans || [])) {
    if (!byMon.has(lhp.monHocId)) byMon.set(lhp.monHocId, { ten: lhp.monHocTen, items: [], soTc: lhp.soTc });
    byMon.get(lhp.monHocId).items.push(lhp);
  }

  const items = [...byMon.entries()].map(([monId, mon]) => ({
    key: String(monId),
    label: `${mon.ten} (${mon.soTc} TC)`,
    children: (
      <div>
        {mon.items.map((lhp) => {
          const selected = lhp.daDangKy || selectedIds.has(lhp.id);
          const disabled = !tickable(lhp);
          const conflicts = conflictsFor(lhp).length;
          return (
            <LhpRow key={lhp.id} lhp={lhp} selected={selected} disabled={disabled}
                    conflictCount={conflicts} onToggle={() => onToggle(lhp)} />
          );
        })}
      </div>
    )
  }));

  return <Collapse items={items} defaultActiveKey={items.map(i => i.key)} />;
}
