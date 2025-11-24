import type { VxeGridProps } from '#/adapter/vxe-table';

import { type VbenFormProps } from '@vben/common-ui';
import { $t } from '@vben/locales';

import { z } from '#/adapter/form';

export const tableColumns: VxeGridProps = {
  columns: [
    {
      type: 'checkbox',
      width: 60,
    },

    {
      title: $t('common.name'), //名称
      field: 'name',
    },
    {
      title: $t('sys.oauth.clientId'), //客户端ID
      field: 'clientId',
    },
    {
      title: $t('common.createTime'), //创建时间
      field: 'createdAt',
      formatter: 'formatDateTime',
    },
  ],
};

export const searchFormSchemas: VbenFormProps = {
  schema: [
    {
      fieldName: 'name',
      label: $t('common.name'), //名称
      component: 'Input',
      rules: z.string().max(30).optional(),
    },
  ],
};

export const dataFormSchemas: VbenFormProps = {
  schema: [
    {
      fieldName: 'id',
      label: 'ID',
      component: 'Input',
      dependencies: {
        show: false,
        triggerFields: ['id'],
      },
    },
    {
      fieldName: 'name',
      label: $t('common.name'), //名称
      component: 'Input',
      rules: z.string().max(30),
    },
    {
      fieldName: 'clientId',
      label: $t('sys.oauth.clientId'), //客户端ID
      component: 'Input',
      rules: z.string().max(80),
    },
    {
      fieldName: 'clientSecret',
      label: $t('sys.oauth.clientSecret'), //客户端密码
      component: 'Input',
      rules: z.string().max(100),
    },
    {
      fieldName: 'redirectUrl',
      label: $t('sys.oauth.redirectURL'), //重定向地址
      component: 'Input',
      rules: z.string().max(300),
    },
    {
      fieldName: 'scopes',
      label: $t('sys.oauth.scope'), //权限范围
      component: 'Input',
      rules: z.string().max(100),
    },
    {
      fieldName: 'authUrl',
      label: $t('sys.oauth.authURL'), //鉴权地址
      component: 'Input',
      rules: z.string().max(300),
    },
    {
      fieldName: 'tokenUrl',
      label: $t('sys.oauth.tokenURL'), //获取Token的地址
      component: 'Input',
      rules: z.string().max(300),
    },
    {
      fieldName: 'infoUrl',
      label: $t('sys.oauth.infoURL'), //获取个人信息地址
      component: 'Input',
      rules: z.string().max(300),
    },
    {
      fieldName: 'authStyle',
      label: $t('sys.oauth.authStyle'), //鉴权方式
      component: 'Select',
      componentProps: {
        options: [
          { label: $t('sys.oauth.params'), value: 1 }, //参数模式
          { label: $t('sys.oauth.header'), value: 2 }, //header模式
        ],
        class: 'w-full',
      },
    },
  ],
};
