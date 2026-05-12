import { useEffect, useState, useMemo } from 'react';
import { Card, Tree, Input, Button, Modal, Form, Select, Space, Spin, Empty, Descriptions, Popconfirm, message, Tag, Table, Badge } from 'antd';
import { Plus, Pencil, Trash2, Building2, BookOpen, Layers, Users, ChevronRight, Download, Upload } from 'lucide-react';
import { adminApi } from '../../../api/endpoints/admin';
import * as XLSX from 'xlsx';

const NODE_ICON = {
  truong: <Building2 size={14} style={{ color: '#722ed1' }} />,
  khoa: <Layers size={14} style={{ color: '#1677ff' }} />,
  bomon: <BookOpen size={14} style={{ color: '#52c41a' }} />,
  lophc: <Users size={14} style={{ color: '#fa8c16' }} />,
};

const NODE_LABEL = { truong: 'Trường', khoa: 'Khoa', bomon: 'Bộ môn', lophc: 'Lớp hành chính' };

export default function KhoaBoMon() {
  const [truongs, setTruongs] = useState([]);
  const [khoas, setKhoas] = useState([]);
  const [boMons, setBoMons] = useState([]);
  const [lopHCs, setLopHCs] = useState([]);
  const [nganhs, setNganhs] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [selected, setSelected] = useState(null);
  const [expanded, setExpanded] = useState([]);
  const [modal, setModal] = useState({ open: false, type: null, editing: null });
  const [form] = Form.useForm();

  const load = async () => {
    setLoading(true);
    const [t, k, b, l, n] = await Promise.all([
      adminApi.truongs(), adminApi.khoas(), adminApi.boMons(),
      adminApi.lopHanhChinhs(), adminApi.nganhs(),
    ]);
    setTruongs(t); setKhoas(k); setBoMons(b); setLopHCs(l); setNganhs(n);
    setLoading(false);
  };
  useEffect(() => { load(); }, []);

  /* Build hierarchical tree:
     Truong -> Khoa -> [Bộ môn children, Lớp HC children] */
  const treeData = useMemo(() => {
    return truongs.map(t => ({
      key: `truong-${t.id}`, title: t.ten, icon: NODE_ICON.truong,
      nodeType: 'truong', data: t,
      children: khoas.filter(k => k.truongId === t.id).map(k => ({
        key: `khoa-${k.id}`, title: k.ten, icon: NODE_ICON.khoa,
        nodeType: 'khoa', data: k,
        children: [
          ...boMons.filter(b => b.khoaId === k.id).map(b => ({
            key: `bomon-${b.id}`, title: b.ten, icon: NODE_ICON.bomon,
            nodeType: 'bomon', data: b,
          })),
          ...lopHCs.filter(l => {
            const nganh = nganhs.find(n => n.id === l.nganhId);
            return nganh && nganh.khoaId === k.id;
          }).map(l => ({
            key: `lophc-${l.id}`, title: l.tenLop ?? l.ten, icon: NODE_ICON.lophc,
            nodeType: 'lophc', data: l,
          })),
        ],
      })),
    }));
  }, [truongs, khoas, boMons, lopHCs, nganhs]);

  /* Auto-expand on search */
  const searchExpandedKeys = useMemo(() => {
    if (!search) return null;
    const keys = new Set();
    const lower = search.toLowerCase();
    lopHCs.forEach(l => {
      const name = l.tenLop ?? l.ten ?? '';
      if (name.toLowerCase().includes(lower)) {
        const nganh = nganhs.find(n => n.id === l.nganhId);
        if (nganh) {
          keys.add(`khoa-${nganh.khoaId}`);
          const k = khoas.find(k2 => k2.id === nganh.khoaId);
          if (k) keys.add(`truong-${k.truongId}`);
        }
      }
    });
    boMons.forEach(b => {
      if (b.ten?.toLowerCase().includes(lower)) {
        const k = khoas.find(k2 => k2.id === b.khoaId);
        if (k) { keys.add(`khoa-${k.id}`); keys.add(`truong-${k.truongId}`); }
      }
    });
    khoas.forEach(k => {
      if (k.ten?.toLowerCase().includes(lower)) keys.add(`truong-${k.truongId}`);
    });
    return [...keys];
  }, [search, truongs, khoas, boMons, lopHCs, nganhs]);

  /* Initialize expanded keys when data loads */
  useEffect(() => {
    if (truongs.length > 0 && expanded.length === 0) {
      setExpanded(truongs.map(t => `truong-${t.id}`));
    }
  }, [truongs]);

  const activeExpanded = searchExpandedKeys ?? expanded;

  const onSelect = (_, { node }) => setSelected(node);

  const openCreate = (type) => {
    form.resetFields();
    if (type === 'khoa' && selected?.nodeType === 'truong') form.setFieldsValue({ truongId: selected.data.id });
    if (type === 'bomon' && selected?.nodeType === 'khoa') form.setFieldsValue({ khoaId: selected.data.id });
    if (type === 'lophc' && selected?.nodeType === 'khoa') {
      const khoaNganhs = nganhs.filter(n => n.khoaId === selected.data.id);
      if (khoaNganhs.length === 1) form.setFieldsValue({ nganhId: khoaNganhs[0].id });
    }
    setModal({ open: true, type, editing: null });
  };

  const openEdit = () => {
    if (!selected) return;
    form.setFieldsValue(selected.data);
    setModal({ open: true, type: selected.nodeType, editing: selected.data });
  };

  const handleDelete = async () => {
    if (!selected) return;
    const { nodeType, data } = selected;
    const fn = {
      truong: adminApi.deleteTruong,
      khoa: adminApi.deleteKhoa,
      bomon: adminApi.deleteBoMon,
      lophc: adminApi.deleteLopHanhChinh,
    }[nodeType];
    await fn(data.id);
    message.success('Đã xóa');
    setSelected(null);
    load();
  };

  const handleSubmit = async () => {
    const values = await form.validateFields();
    const { type, editing } = modal;
    if (editing) {
      const fn = {
        truong: adminApi.updateTruong,
        khoa: adminApi.updateKhoa,
        bomon: adminApi.updateBoMon,
        lophc: adminApi.updateLopHanhChinh,
      }[type];
      await fn(editing.id, values);
    } else {
      const fn = {
        truong: adminApi.createTruong,
        khoa: adminApi.createKhoa,
        bomon: adminApi.createBoMon,
        lophc: adminApi.createLopHanhChinh,
      }[type];
      await fn(values);
    }
    message.success('Đã lưu');
    setModal({ open: false, type: null, editing: null });
    load();
  };

  /* Export the tree as flat Excel */
  const handleExport = () => {
    const rows = [];
    truongs.forEach(t => {
      khoas.filter(k => k.truongId === t.id).forEach(k => {
        boMons.filter(b => b.khoaId === k.id).forEach(b => {
          rows.push({ 'Trường': t.ten, 'Khoa': k.ten, 'Loại': 'Bộ môn', 'Tên': b.ten, 'Mô tả': b.mota ?? '' });
        });
        lopHCs.filter(l => {
          const n = nganhs.find(ng => ng.id === l.nganhId);
          return n && n.khoaId === k.id;
        }).forEach(l => {
          rows.push({ 'Trường': t.ten, 'Khoa': k.ten, 'Loại': 'Lớp HC', 'Tên': l.tenLop ?? l.ten, 'Mô tả': '' });
        });
      });
    });
    const ws = XLSX.utils.json_to_sheet(rows);
    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, 'CoChuc');
    XLSX.writeFile(wb, 'co_cau_to_chuc.xlsx');
  };

  const renderForm = () => {
    const { type } = modal;
    return (
      <>
        {type !== 'lophc' && (
          <Form.Item name="ten" label="Tên" rules={[{ required: true }]}><Input /></Form.Item>
        )}
        {type !== 'lophc' && (
          <Form.Item name="mota" label="Mô tả"><Input /></Form.Item>
        )}
        {type === 'khoa' && (
          <Form.Item name="truongId" label="Trường" rules={[{ required: true }]}>
            <Select options={truongs.map(t => ({ value: t.id, label: t.ten }))} />
          </Form.Item>
        )}
        {type === 'bomon' && (
          <Form.Item name="khoaId" label="Khoa" rules={[{ required: true }]}>
            <Select options={khoas.map(k => ({ value: k.id, label: k.ten }))} />
          </Form.Item>
        )}
        {type === 'lophc' && (
          <>
            <Form.Item name="tenLop" label="Tên lớp" rules={[{ required: true }]}><Input /></Form.Item>
            <Form.Item name="nganhId" label="Ngành" rules={[{ required: true }]}>
              <Select options={nganhs.map(n => ({ value: n.id, label: n.ten }))} showSearch optionFilterProp="label" />
            </Form.Item>
          </>
        )}
      </>
    );
  };

  const detailNode = selected?.data;
  const nodeType = selected?.nodeType;
  const nodeLabel = NODE_LABEL[nodeType] ?? '';

  /* Build detail stats for selected node */
  const childStats = useMemo(() => {
    if (!selected) return null;
    if (nodeType === 'truong') {
      const khoaCount = khoas.filter(k => k.truongId === detailNode.id).length;
      const boMonCount = boMons.filter(b => khoas.some(k => k.id === b.khoaId && k.truongId === detailNode.id)).length;
      return [
        { label: 'Số khoa', value: khoaCount },
        { label: 'Tổng bộ môn', value: boMonCount },
      ];
    }
    if (nodeType === 'khoa') {
      const bmCount = boMons.filter(b => b.khoaId === detailNode.id).length;
      const lopCount = lopHCs.filter(l => {
        const n = nganhs.find(ng => ng.id === l.nganhId);
        return n && n.khoaId === detailNode.id;
      }).length;
      return [
        { label: 'Bộ môn', value: bmCount },
        { label: 'Lớp HC', value: lopCount },
      ];
    }
    return null;
  }, [selected, khoas, boMons, lopHCs, nganhs]);

  if (loading) return <Spin style={{ display: 'block', margin: '80px auto' }} />;

  return (
    <div className="fade-in" style={{ display: 'flex', gap: 14, minHeight: 520 }}>
      {/* Tree panel */}
      <Card size="small" style={{ width: 380, flexShrink: 0, borderRadius: 10, boxShadow: '0 2px 8px rgba(0,0,0,0.06)' }}
        title={<span style={{ fontWeight: 600 }}><Building2 size={14} style={{ marginRight: 6, verticalAlign: -2 }} />Cơ cấu tổ chức</span>}
        extra={
          <Space size={4}>
            <Button size="small" icon={<Download size={12} />} onClick={handleExport} title="Xuất Excel" />
            <Button size="small" type="primary" onClick={() => openCreate(nodeType === 'khoa' ? 'bomon' : nodeType === 'truong' ? 'khoa' : 'truong')}>
              <Plus size={12} /> Thêm
            </Button>
          </Space>
        }>
        <Input.Search placeholder="Tìm kiếm..." allowClear onChange={e => setSearch(e.target.value)} style={{ marginBottom: 10 }} size="small" />

        <div style={{ display: 'flex', gap: 4, marginBottom: 10, flexWrap: 'wrap' }}>
          <Button size="small" type="dashed" onClick={() => openCreate('truong')}>+ Trường</Button>
          <Button size="small" type="dashed" onClick={() => openCreate('khoa')}>+ Khoa</Button>
          <Button size="small" type="dashed" onClick={() => openCreate('bomon')}>+ Bộ môn</Button>
          <Button size="small" type="dashed" onClick={() => openCreate('lophc')}>+ Lớp HC</Button>
        </div>

        {treeData.length === 0 ? <Empty description="Chưa có dữ liệu" /> : (
          <Tree showIcon showLine treeData={treeData}
            expandedKeys={activeExpanded}
            onExpand={(keys) => { if (!search) setExpanded(keys); }}
            autoExpandParent={!!search}
            onSelect={onSelect}
            selectedKeys={selected ? [selected.key] : []}
            filterTreeNode={(node) => {
              if (!search) return false;
              const title = typeof node.title === 'string' ? node.title : '';
              return title.toLowerCase().includes(search.toLowerCase());
            }}
            style={{ fontSize: 13 }} />
        )}
      </Card>

      {/* Detail panel */}
      <Card size="small" style={{ flex: 1, borderRadius: 10, boxShadow: '0 2px 8px rgba(0,0,0,0.06)' }}
        title={
          detailNode
            ? <Space><Tag color={nodeType === 'truong' ? 'purple' : nodeType === 'khoa' ? 'blue' : nodeType === 'bomon' ? 'green' : 'orange'}>{nodeLabel}</Tag><span style={{ fontWeight: 600 }}>{detailNode.ten ?? detailNode.tenLop}</span></Space>
            : <span style={{ color: '#999' }}>Chi tiết</span>
        }
        extra={detailNode && (
          <Space>
            <Button size="small" icon={<Pencil size={14} />} onClick={openEdit}>Sửa</Button>
            <Popconfirm title="Xóa?" onConfirm={handleDelete}>
              <Button size="small" danger icon={<Trash2 size={14} />}>Xóa</Button>
            </Popconfirm>
          </Space>
        )}>
        {detailNode ? (
          <div className="fade-in">
            {/* Quick stat badges */}
            {childStats && (
              <div style={{ display: 'flex', gap: 12, marginBottom: 16 }}>
                {childStats.map(s => (
                  <Card key={s.label} size="small" style={{ flex: 1, textAlign: 'center', borderRadius: 8 }}>
                    <div style={{ fontSize: 24, fontWeight: 700, color: '#1677ff' }}>{s.value}</div>
                    <div style={{ fontSize: 12, color: '#888' }}>{s.label}</div>
                  </Card>
                ))}
              </div>
            )}
            <Descriptions column={1} bordered size="small">
              <Descriptions.Item label="ID">{detailNode.id}</Descriptions.Item>
              <Descriptions.Item label="Tên">{detailNode.ten ?? detailNode.tenLop}</Descriptions.Item>
              {detailNode.mota && <Descriptions.Item label="Mô tả">{detailNode.mota}</Descriptions.Item>}
              {nodeType === 'lophc' && (
                <Descriptions.Item label="Ngành">
                  {nganhs.find(n => n.id === detailNode.nganhId)?.ten ?? detailNode.nganhId}
                </Descriptions.Item>
              )}
            </Descriptions>

            {/* Show children list for khoa */}
            {nodeType === 'khoa' && (
              <div style={{ marginTop: 16 }}>
                <h4 style={{ fontSize: 13, fontWeight: 600, marginBottom: 8 }}>Bộ môn trực thuộc</h4>
                <Table size="small" rowKey="id" pagination={false}
                  dataSource={boMons.filter(b => b.khoaId === detailNode.id)}
                  columns={[
                    { title: 'Tên', dataIndex: 'ten' },
                    { title: 'Mô tả', dataIndex: 'mota' },
                  ]} />
              </div>
            )}
          </div>
        ) : (
          <Empty description="Chọn một mục từ cây bên trái" style={{ marginTop: 60 }} />
        )}
      </Card>

      <Modal title={modal.editing ? `Sửa ${NODE_LABEL[modal.type] ?? ''}` : `Thêm ${NODE_LABEL[modal.type] ?? ''}`}
        open={modal.open} onOk={handleSubmit} onCancel={() => setModal({ open: false, type: null, editing: null })}
        destroyOnClose>
        <Form form={form} layout="vertical">{renderForm()}</Form>
      </Modal>
    </div>
  );
}
