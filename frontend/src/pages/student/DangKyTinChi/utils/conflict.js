export const slotKey = (b) => `${b.tuan}:${b.ngay}:${b.kip}`;

export function lhpConflicts(target, others) {
  const otherKeys = new Set(others.flatMap(o => o.lich.map(slotKey)));
  return target.lich.filter(b => otherKeys.has(slotKey(b)));
}

export function occupiedSlots(lhpList) {
  return new Set(lhpList.flatMap(l => l.lich.map(slotKey)));
}
