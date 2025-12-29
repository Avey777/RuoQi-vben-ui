import type { DataNode } from 'ant-design-vue/es/vc-tree/interface';

import type { Recordable } from '@vben/types';

import { array2tree } from '@axolo/tree-array';
import { map } from 'remeda';

export interface buildNodeOption {
  labelField: string;
  idKeyField: string;
  valueField: string;
  parentKeyField: string;
  defaultValue?: Recordable<any> | string;
  childrenKeyField: string;
}

/**
 * 确保值为字符串类型
 */
function ensureString(value: any): string {
  if (value === null) return '';
  return String(value);
}

/**
 * 解析 trans 字段获取标题
 */
function parseTransTitle(transValue: any): string {
  if (typeof transValue === 'string') {
    try {
      const parsed = JSON.parse(transValue);
      return (
        parsed.title ||
        parsed.name ||
        Object.values(parsed).find(Boolean) ||
        transValue
      );
    } catch {
      return transValue;
    }
  }

  if (typeof transValue === 'object' && transValue !== null) {
    return (
      transValue.title ||
      transValue.name ||
      Object.values(transValue).find(Boolean) ||
      '未命名'
    );
  }

  return ensureString(transValue);
}

/**
 * 构建树节点基础数据
 */
function buildNodeBaseData<T extends Recordable<any>>(
  obj: T,
  options: buildNodeOption,
  isDataNode: boolean,
): Recordable<any> {
  const result: Recordable<any> = {};

  // 处理 ID 字段
  if (obj[options.idKeyField] !== undefined) {
    result[options.idKeyField] = ensureString(obj[options.idKeyField]);
  }

  // 处理父级字段
  if (obj[options.parentKeyField] !== undefined) {
    result[options.parentKeyField] = ensureString(obj[options.parentKeyField]);
  }

  // 处理值字段
  if (obj[options.valueField] !== undefined) {
    const value = ensureString(obj[options.valueField]);
    if (isDataNode) {
      result.key = value;
    } else {
      result.value = value;
    }
  }

  // 处理标签字段
  if (obj[options.labelField] !== undefined) {
    const labelValue = obj[options.labelField];
    result.title =
      options.labelField === 'trans'
        ? parseTransTitle(labelValue)
        : ensureString(labelValue);

    // 对于非 DataNode 类型，添加 label 字段
    if (!isDataNode) {
      result.label = result.title;
    }
  }

  return result;
}

/**
 * 将数组数据转换为 DataNode 树结构
 */
export function buildDataNode<T extends Recordable<any>>(
  data: T[],
  options: buildNodeOption,
): DataNode[] {
  const treeNodeData = map(data, (obj) =>
    buildNodeBaseData(obj, options, true),
  );

  const treeConv = array2tree(treeNodeData, {
    idKey: options.idKeyField,
    parentKey: options.parentKeyField,
    childrenKey: options.childrenKeyField,
  });

  if (options.defaultValue) {
    treeConv.push(options.defaultValue as Recordable<any>);
  }

  return treeConv as DataNode[];
}

/**
 * 将数组数据转换为通用树结构
 */
export function buildTreeNode<T extends Recordable<any>>(
  data: T[],
  options: buildNodeOption,
): Recordable<any>[] {
  const treeNodeData = map(data, (obj) => {
    const baseData = buildNodeBaseData(obj, options, false);

    // 直接使用 baseData，不需要解构 labelField 和 valueField
    // 因为这些字段实际上不存在于 baseData 中
    return {
      ...baseData,
      // 确保有 label 字段
      label: baseData.title || '',
      // 确保有 value 字段
      value: baseData.value || '',
    };
  });

  const treeConv = array2tree(treeNodeData, {
    idKey: options.idKeyField,
    parentKey: options.parentKeyField,
    childrenKey: options.childrenKeyField,
  });

  if (options.defaultValue) {
    treeConv.push(options.defaultValue as Recordable<any>);
  }
  return treeConv as Recordable<any>[];
}
