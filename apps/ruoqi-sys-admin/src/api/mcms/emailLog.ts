import type { EmailLogInfo, EmailLogListResp } from './model/emailLogModel';

import type {
  BaseDataResp,
  BaseListReq,
  BaseResp,
  BaseUUIDReq,
  BaseUUIDsReq,
} from '#/api/model/baseModel';

import { requestClient } from '#/api/request';

enum Api {
  CreateEmailLog = '/sys_admin/email_log/create',
  DeleteEmailLog = '/sys_admin/email_log/delete',
  GetEmailLogById = '/sys_admin/email_log',
  GetEmailLogList = '/sys_admin/email_log/list',
  UpdateEmailLog = '/sys_admin/email_log/update',
}

/**
 * @description: Get email log list
 */

export const getEmailLogList = (params: BaseListReq) => {
  return requestClient.post<BaseDataResp<EmailLogListResp>>(
    Api.GetEmailLogList,
    params,
  );
};

/**
 *  @description: Create a new email log
 */
export const createEmailLog = (params: EmailLogInfo) => {
  return requestClient.post<BaseResp>(Api.CreateEmailLog, params);
};

/**
 *  @description: Update the email log
 */
export const updateEmailLog = (params: EmailLogInfo) => {
  return requestClient.post<BaseResp>(Api.UpdateEmailLog, params);
};

/**
 *  @description: Delete email logs
 */
export const deleteEmailLog = (params: BaseUUIDsReq) => {
  return requestClient.post<BaseResp>(Api.DeleteEmailLog, params);
};

/**
 *  @description: Get email log By ID
 */
export const getEmailLogById = (params: BaseUUIDReq) => {
  return requestClient.post<BaseDataResp<EmailLogInfo>>(
    Api.GetEmailLogById,
    params,
  );
};
