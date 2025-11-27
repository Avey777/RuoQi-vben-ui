import type { TaskInfo, TaskListResp } from './model/taskModel';

import type {
  BaseDataResp,
  BaseIDReq,
  BaseIDsReq,
  BaseListReq,
  BaseResp,
} from '#/api/model/baseModel';

import { requestClient } from '#/api/request';

enum Api {
  CreateTask = '/sys_admin/task/create',
  DeleteTask = '/sys_admin/task/delete',
  GetTaskById = '/sys_admin/task',
  GetTaskList = '/sys_admin/task/list',
  UpdateTask = '/sys_admin/task/update',
}

/**
 * @description: Get task list
 */

export const getTaskList = (params: BaseListReq) => {
  return requestClient.post<BaseDataResp<TaskListResp>>(
    Api.GetTaskList,
    params,
  );
};

/**
 *  @description: Create a new task
 */
export const createTask = (params: TaskInfo) => {
  return requestClient.post<BaseResp>(Api.CreateTask, params);
};

/**
 *  @description: Update the task
 */
export const updateTask = (params: TaskInfo) => {
  return requestClient.post<BaseResp>(Api.UpdateTask, params);
};

/**
 *  @description: Delete tasks
 */
export const deleteTask = (params: BaseIDsReq) => {
  return requestClient.post<BaseResp>(Api.DeleteTask, params);
};

/**
 *  @description: Get task By ID
 */
export const getTaskById = (params: BaseIDReq) => {
  return requestClient.post<BaseDataResp<TaskInfo>>(Api.GetTaskById, params);
};
