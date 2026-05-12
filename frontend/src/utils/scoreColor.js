export function scoreColor(v) {
  if (v == null) return '#999';
  if (v >= 8)   return '#2E7D32';
  if (v >= 6.5) return '#1677ff';
  if (v >= 5)   return '#F57C00';
  return '#D32F2F';
}
