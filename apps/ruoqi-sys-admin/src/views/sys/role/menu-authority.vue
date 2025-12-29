<script lang="ts" setup>
import type { DataNode } from 'ant-design-vue/es/vc-tree/interface';

import { ref } from 'vue';

import { useVbenModal } from '@vben/common-ui';
import { $t } from '@vben/locales';

import { message, Tree } from 'ant-design-vue';

import {
  createOrUpdateMenuAuthority,
  getMenuAuthority,
} from '#/api/sys/authority';
import { getMenuList } from '#/api/sys/menu';
import { buildDataNode } from '#/utils/tree';

defineOptions({
  name: 'MenuAuthorityModal',
});

const treeMenuData = ref<DataNode[]>([]);

const checkedKeys = ref<string[]>([]);
const expandedKeys = ref<string[]>([]);
const roleId = ref<string>('');

const [Modal, modalApi] = useVbenModal({
  fullscreenButton: false,
  onCancel() {
    modalApi.close();
  },
  onConfirm: async () => {
    const currentRoleId = String(roleId.value || '');

    const result = await createOrUpdateMenuAuthority({
      roleId: currentRoleId,
      menuIds: checkedKeys.value || [], // 使用空数组作为默认值
    });

    if (result.code === 0) {
      message.success($t('common.successful'));
    } else {
      message.error(result.msg || $t('common.failed'));
    }
    modalApi.close();
  },
  onOpenChange(isOpen: boolean) {
    const data = modalApi.getData();
    roleId.value = isOpen ? String(data?.roleId || '') : '';
    if (isOpen && roleId.value) {
      getMenuData(roleId.value);
    }
  },
  title: $t('sys.authority.menuAuthority'),
});

async function getMenuData(roleId: string) {
  try {
    treeMenuData.value = [];
    const data = await getMenuList();
    treeMenuData.value = buildDataNode(data.data.data, {
      idKeyField: 'id',
      parentKeyField: 'parentId',
      childrenKeyField: 'children',
      valueField: 'id',
      labelField: 'trans',
    });

    const checkedData = await getMenuAuthority({ id: roleId });
    const menuIds = checkedData.data.menuIds || [];
    checkedKeys.value = menuIds.map(String);
    expandedKeys.value = data.data.data.map((val, _idx, _arr) =>
      String(val.id),
    );
  } catch (error) {
    console.error('Error in getMenuData:', error);
    // 参考 ApiAuthorityModal，这里也静默处理错误
  }
}

defineExpose(modalApi);
</script>
<template>
  <Modal>
    <Tree
      v-model:checked-keys="checkedKeys"
      v-model:expanded-keys="expandedKeys"
      :tree-data="treeMenuData"
      check-strictly
      checkable
      default-expand-all
    />
  </Modal>
</template>
