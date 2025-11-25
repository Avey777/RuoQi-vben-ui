import {
  type BaseDataResp,
  type BaseIDReq,
  type BaseIDsReq,
  type BaseListReq,
  type BaseResp,
} from '#/api/model/baseModel';
import { requestClient } from '#/api/request';

import { type RoleInfo, type RoleListResp } from './model/roleModel';

enum Api {
  CreateRole = '/sys-admin/role/create',
  DeleteRole = '/sys-admin/role/delete',
  GetRoleById = '/sys-admin/role',
  GetRoleList = '/sys-admin/role/list',
  UpdateRole = '/sys-admin/role/update',
}

/**
 * @description: Get role list
 */

export const getRoleList = (params: BaseListReq) => {
  return requestClient.post<BaseDataResp<RoleListResp>>(
    Api.GetRoleList,
    params,
  );
};

/**
 *  @description: Create a new role
 */
export const createRole = (params: RoleInfo) => {
  return requestClient.post<BaseResp>(Api.CreateRole, params);
};

/**
 *  @description: Update the role
 */
export const updateRole = (params: RoleInfo) => {
  return requestClient.post<BaseResp>(Api.UpdateRole, params);
};

/**
 *  @description: Delete roles
 */
export const deleteRole = (params: BaseIDsReq) => {
  return requestClient.post<BaseResp>(Api.DeleteRole, params);
};

/**
 *  @description: Get role By ID
 */
export const getRoleById = (params: BaseIDReq) => {
  return requestClient.post<BaseDataResp<RoleInfo>>(Api.GetRoleById, params);
};
