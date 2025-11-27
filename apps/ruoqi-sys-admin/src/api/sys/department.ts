import type {
  DepartmentInfo,
  DepartmentListResp,
} from './model/departmentModel';

import type {
  BaseDataResp,
  BaseIDReq,
  BaseIDsReq,
  BaseListReq,
  BaseResp,
} from '#/api/model/baseModel';

import { requestClient } from '#/api/request';

enum Api {
  CreateDepartment = '/sys_admin/department/create',
  DeleteDepartment = '/sys_admin/department/delete',
  GetDepartmentById = '/sys_admin/department',
  GetDepartmentList = '/sys_admin/department/list',
  UpdateDepartment = '/sys_admin/department/update',
}

/**
 * @description: Get department list
 */

export const getDepartmentList = (params: BaseListReq) => {
  return requestClient.post<BaseDataResp<DepartmentListResp>>(
    Api.GetDepartmentList,
    params,
  );
};

/**
 *  @description: Create a new department
 */
export const createDepartment = (params: DepartmentInfo) => {
  return requestClient.post<BaseResp>(Api.CreateDepartment, params);
};

/**
 *  @description: Update the department
 */
export const updateDepartment = (params: DepartmentInfo) => {
  return requestClient.post<BaseResp>(Api.UpdateDepartment, params);
};

/**
 *  @description: Delete departments
 */
export const deleteDepartment = (params: BaseIDsReq) => {
  return requestClient.post<BaseResp>(Api.DeleteDepartment, params);
};

/**
 *  @description: Get department By ID
 */
export const getDepartmentById = (params: BaseIDReq) => {
  return requestClient.post<BaseDataResp<DepartmentInfo>>(
    Api.GetDepartmentById,
    params,
  );
};
