<script lang="ts" setup>
import type { DataNode } from 'ant-design-vue/es/vc-tree/interface';

import type { BaseDataResp } from '#/api/model/baseModel';
import type { ApiInfo, ApiListResp } from '#/api/sys/model/apiModel';
import type { ApiAuthorityInfo } from '#/api/sys/model/authorityModel';

import { ref } from 'vue';

import { useVbenModal } from '@vben/common-ui';
import { $t } from '@vben/locales';

import { message, Tree } from 'ant-design-vue';
import { clone } from 'remeda';

import {
  createOrUpdateApiAuthority,
  getApiAuthority,
  getApiList,
} from '#/api/sys/authority';

defineOptions({
  name: 'ApiAuthorityModal',
});

const treeApiData = ref<DataNode[]>([]);

const checkedKeys = ref<string[]>([]);
const roleId = ref<string>();
let tempApiList: BaseDataResp<ApiListResp> = {
  code: 0,
  msg: '',
  data: { total: 0, data: [] },
};

const [Modal, modalApi] = useVbenModal({
  fullscreenButton: false,
  onCancel() {
    modalApi.close();
  },
  onConfirm: async () => {
    // 修复：从 checkedKeys 中提取纯数字的API ID
    const apiReqData = extractApiIdsFromCheckedKeys(
      checkedKeys.value,
      tempApiList.data.data,
    );

    if (apiReqData.length === 0) {
      message.warning($t('sys.authority.selectAtLeastOneApi'));
      return;
    }

    const result = await createOrUpdateApiAuthority({
      roleId: String(roleId.value),
      apiIds: apiReqData,
    });

    if (result.code === 0) {
      message.success($t('common.successful'));
    } else {
      message.error(result.msg || $t('common.failed'));
    }
    modalApi.close();
  },
  onOpenChange(isOpen: boolean) {
    roleId.value = isOpen ? modalApi.getData()?.roleId || {} : {};
    if (isOpen) {
      getApiData();
    }
  },
  title: $t('sys.authority.apiAuthority'),
});

async function getApiData() {
  try {
    treeApiData.value = [];
    checkedKeys.value = [];
    const apiData = await getApiList({
      page: 1,
      pageSize: 10_000,
    });
    tempApiList = apiData;
    const dataConv = convertApiTreeData(apiData.data.data);
    for (const key in dataConv) {
      treeApiData.value.push(dataConv[key] as any);
    }
    const checkedData = await getApiAuthority({ id: roleId.value });
    if (checkedData.code === 0 && checkedData.data) {
      // 检查数据是否按分组返回
      if (
        typeof checkedData.data === 'object' &&
        !Array.isArray(checkedData.data)
      ) {
        // 这是按分组返回的数据，如 { user: [...], role: [...], ... }
        const allAuthApis: ApiAuthorityInfo[] = [];

        // 遍历所有分组，提取API数据
        Object.values(checkedData.data).forEach((group: any) => {
          if (Array.isArray(group)) {
            // 提取每个API的授权信息
            group.forEach((api: any) => {
              if (api.path && api.method) {
                // 提取API授权信息
                allAuthApis.push({
                  path: api.path,
                  method: api.method,
                });
              }
            });
          }
        });

        // 转换为checked keys
        const checkedApiKeys = convertApiToCheckedKeys(
          allAuthApis,
          apiData.data.data,
        );
        checkedKeys.value = checkedApiKeys;
      } else if (Array.isArray(checkedData.data)) {
        // 如果直接返回数组
        const checkedApiKeys = convertApiToCheckedKeys(
          checkedData.data,
          apiData.data.data,
        );
        checkedKeys.value = checkedApiKeys;
      } else {
        // 默认只添加必须的API
        const requiredKeys = getRequiredApiKeys(apiData.data.data);
        checkedKeys.value = requiredKeys;
      }
    } else {
      // 如果没有已授权数据，只添加必须的API
      const requiredKeys = getRequiredApiKeys(apiData.data.data);
      checkedKeys.value = requiredKeys;
    }
  } catch (error) {
    console.error('获取API数据失败:', error);
    message.error($t('common.loadFailed'));
  }
}

/**
 * 获取必须的API keys
 */
function getRequiredApiKeys(apiData: ApiInfo[]): string[] {
  return apiData
    .filter((api) => api.isRequired && api.id)
    .map((api) => api.id!);
}

/**
 *  author: DoDo
 *  @description: this function is used to convert menu data into tree node data
 */

function convertApiTreeData(params: ApiInfo[]): DataNode[] {
  const finalData: DataNode[] = [];
  const apiData: DataNode[] = [];
  if (params.length === 0) {
    return apiData;
  }

  const apiMap = new Map<string, string>();
  const serviceMap = new Map<string, boolean>();
  for (const param of params) {
    apiMap.set(param.group, param.serviceName);
    serviceMap.set(param.serviceName, true);
  }

  for (const k of apiMap.keys()) {
    const apiTmp: DataNode = {
      title: k,
      key: k,
      children: [],
    };

    for (const param of params) {
      if (param.group === k) {
        apiTmp.children?.push({
          title: param.trans,
          key: param.id as string,
          disableCheckbox: param.isRequired,
        });
      }
    }

    apiData.push(apiTmp);
  }

  for (const k1 of serviceMap.keys()) {
    const svcTmp: DataNode = {
      title: k1,
      key: k1,
      children: [],
    };

    for (const apiDatum of apiData) {
      if (apiMap.get(apiDatum.title) === k1) {
        svcTmp.children?.push(clone(apiDatum));
      }
    }

    finalData.push(svcTmp);
  }

  return finalData;
}

/**
 *  author: DoDo
 *  @description: convert checked data into authorized data
 */
function extractApiIdsFromCheckedKeys(
  checkedKeys: string[],
  apiData: ApiInfo[],
): ApiAuthorityInfo[] {
  const apiInfos: ApiAuthorityInfo[] = [];
  const apiDataMap = new Map<string, ApiInfo>();

  // 创建API ID到ApiInfo的映射
  apiData.forEach((api) => {
    if (api.id) {
      apiDataMap.set(api.id, api);
    }
  });

  // 过滤出有效的 API 并转换为 ApiAuthorityInfo
  checkedKeys.forEach((key) => {
    const apiInfo = apiDataMap.get(key);
    if (apiInfo && apiInfo.path && apiInfo.method) {
      apiInfos.push({
        path: apiInfo.path,
        method: apiInfo.method,
      });
    }
  });

  return apiInfos;
}

/**
 *  author: DoDo
 *  @description: this function is used to convert authorization api response into checked keys
 */
function convertApiToCheckedKeys(
  checked: ApiAuthorityInfo[],
  data: ApiInfo[],
): string[] {
  const dataMap = new Map<string, string>();
  const authorityApis: string[] = [];
  const requiredAPIs: string[] = [];

  // 获取必须的API
  data.forEach((value) => {
    if (value.isRequired && value.id) {
      requiredAPIs.push(value.id);
    }
  });

  // 创建path+method到id的映射
  for (const datum of data) {
    if (datum.id) {
      // 使用多种key格式确保匹配
      const key1 = `${datum.path}|${datum.method}`;
      const key2 = datum.path + datum.method;
      const key3 = `${datum.method}:${datum.path}`;

      dataMap.set(key1, datum.id);
      dataMap.set(key2, datum.id);
      dataMap.set(key3, datum.id);
    }
  }

  // 处理已授权的API
  for (const element of checked) {
    // 尝试不同的key格式
    let apiId = dataMap.get(`${element.path}|${element.method}`);
    if (!apiId) {
      apiId = dataMap.get(element.path + element.method);
    }
    if (!apiId) {
      apiId = dataMap.get(`${element.method}:${element.path}`);
    }

    if (apiId) {
      authorityApis.push(apiId);
    }
  }

  // 合并并去重
  const allChecked = [...authorityApis, ...requiredAPIs];
  const result = [...new Set(allChecked)];
  return result;
}

defineExpose(modalApi);
</script>
<template>
  <Modal>
    <Tree
      v-model:checked-keys="checkedKeys"
      :tree-data="treeApiData"
      checkable
      default-expand-all
    />
  </Modal>
</template>
