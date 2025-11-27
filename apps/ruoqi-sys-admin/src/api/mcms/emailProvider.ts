import type {
  EmailProviderInfo,
  EmailProviderListResp,
} from './model/emailProviderModel';

import type {
  BaseDataResp,
  BaseIDReq,
  BaseIDsReq,
  BaseListReq,
  BaseResp,
} from '#/api/model/baseModel';

import { requestClient } from '#/api/request';

enum Api {
  CreateEmailProvider = '/sys_admin/email_provider/create',
  DeleteEmailProvider = '/sys_admin/email_provider/delete',
  GetEmailProviderById = '/sys_admin/email_provider',
  GetEmailProviderList = '/sys_admin/email_provider/list',
  UpdateEmailProvider = '/sys_admin/email_provider/update',
}

/**
 * @description: Get email provider list
 */

export const getEmailProviderList = (params: BaseListReq) => {
  return requestClient.post<BaseDataResp<EmailProviderListResp>>(
    Api.GetEmailProviderList,
    params,
  );
};

/**
 *  @description: Create a new email provider
 */
export const createEmailProvider = (params: EmailProviderInfo) => {
  return requestClient.post<BaseResp>(Api.CreateEmailProvider, params);
};

/**
 *  @description: Update the email provider
 */
export const updateEmailProvider = (params: EmailProviderInfo) => {
  return requestClient.post<BaseResp>(Api.UpdateEmailProvider, params);
};

/**
 *  @description: Delete email providers
 */
export const deleteEmailProvider = (params: BaseIDsReq) => {
  return requestClient.post<BaseResp>(Api.DeleteEmailProvider, params);
};

/**
 *  @description: Get email provider By ID
 */
export const getEmailProviderById = (params: BaseIDReq) => {
  return requestClient.post<BaseDataResp<EmailProviderInfo>>(
    Api.GetEmailProviderById,
    params,
  );
};
