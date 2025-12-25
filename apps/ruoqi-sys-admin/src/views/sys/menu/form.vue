<script lang="ts" setup>
import type { MenuInfoPlain } from '#/api/sys/model/menuModel';

import { ref } from 'vue';

import { useVbenModal } from '@vben/common-ui';
import { $t } from '@vben/locales';

import { message } from 'ant-design-vue';

import { useVbenForm } from '#/adapter/form';
import { createMenu, updateMenu } from '#/api/sys/menu';

import { dataFormSchemas } from './schemas';

defineOptions({
  name: 'MenuForm',
});

const record = ref();
const isUpdate = ref(false);
const gridApi = ref();

async function onSubmit(values: Record<string, any>) {
  values.id = isUpdate.value ? values.id : undefined;
  if (values.menuType === 2) {
    values.hideMenu = true;
  }

  const result = isUpdate.value
    ? await updateMenu(values as MenuInfoPlain)
    : await createMenu(values as MenuInfoPlain);
  if (result.code === 0) {
    message.success(result.msg);
    gridApi.value.reload();
  }
}

const [Form, formApi] = useVbenForm({
  handleSubmit: onSubmit,
  schema: [...(dataFormSchemas.schema as any)],
  showDefaultActions: false,
  layout: 'vertical',
  commonConfig: {
    // 所有表单项
    componentProps: {
      class: 'w-full',
    },
  },
  wrapperClass: 'grid-cols-2',
});

const [Modal, modalApi] = useVbenModal({
  fullscreenButton: false,
  onCancel() {
    modalApi.close();
  },
  onConfirm: async () => {
    const validationResult = await formApi.validate();
    if (validationResult.valid) {
      await formApi.submitForm();
      modalApi.close();
    }
  },
  onOpenChange(isOpen: boolean) {
    isUpdate.value = modalApi.getData()?.isUpdate;
    record.value = isOpen ? modalApi.getData()?.record || {} : {};
    gridApi.value = isOpen ? modalApi.getData()?.gridApi : null;
    if (isOpen) {
      // 只转换特定的布尔字段
      const processedValues = { ...record.value };

      // 只有这些字段需要从数字转布尔值
      const booleanFields = [
        'disabled',
        'ignoreKeepAlive',
        'hideMenu',
        'hideBreadcrumb',
        'hideTab',
        'carryParam',
        'hideChildrenInMenu',
        'affix',
      ];

      booleanFields.forEach((field) => {
        if (processedValues[field] !== undefined) {
          // 只处理数字 0/1 的情况
          if (processedValues[field] === 0 || processedValues[field] === 1) {
            processedValues[field] = !!processedValues[field];
          }
          // 如果是字符串 '0'/'1' 也转换
          if (
            processedValues[field] === '0' ||
            processedValues[field] === '1'
          ) {
            processedValues[field] = processedValues[field] === '1';
          }
        }
      });

      formApi.setValues(processedValues);
    }
    modalApi.setState({
      title: isUpdate.value ? $t('sys.menu.editMenu') : $t('sys.menu.addMenu'),
    });
  },
});

defineExpose(modalApi);
</script>
<template>
  <Modal class="w-1/2">
    <Form />
  </Modal>
</template>
