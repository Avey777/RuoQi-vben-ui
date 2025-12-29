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
const roleId = ref<string>();

const [Modal, modalApi] = useVbenModal({
  fullscreenButton: false,
  onCancel() {
    modalApi.close();
  },
  onConfirm: async () => {
    if (checkedKeys.value && checkedKeys.value.length > 0) {
      const result = await createOrUpdateMenuAuthority({
        roleId: roleId.value as string,
        menuIds: checkedKeys.value,
      });
      if (result.code === 0) {
        message.success($t('common.successful'));
      }
    }
    modalApi.close();
  },
  onOpenChange(isOpen: boolean) {
    roleId.value = isOpen ? modalApi.getData()?.roleId || '' : '';
    if (isOpen) {
      getMenuData(roleId.value as string);
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
    checkedKeys.value = checkedData.data.menuIds;
    expandedKeys.value = data.data.data.map(
      (val, _idx, _arr) => val.id as string,
    );
  } catch {
    // console.log(error);
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
