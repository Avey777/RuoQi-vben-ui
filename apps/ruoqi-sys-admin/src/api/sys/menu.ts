import {
  type BaseDataResp,
  type BaseIDReq,
  type BaseResp,
} from '#/api/model/baseModel';
import { requestClient } from '#/api/request';

import {
  type MenuInfoPlain,
  type MenuPlainListResp,
  type RoleMenuResp,
} from './model/menuModel';

enum Api {
  CreateMenu = '/sys-admin/menu/create',
  DeleteMenu = '/sys-admin/menu/delete',
  GetMenuById = '/sys-admin/menu',
  GetMenuList = '/sys-admin/menu/list',
  GetMenuListByRole = '/sys-admin/menu/role/list',
  UpdateMenu = '/sys-admin/menu/update',
}

/**
 * @description: Get user menu list by role id
 */

export const getMenuListByRole = () => {
  return requestClient.get<BaseDataResp<RoleMenuResp>>(Api.GetMenuListByRole);
};

/**
 * @description: Get menu list
 */

export const getMenuList = () => {
  return requestClient.get<BaseDataResp<MenuPlainListResp>>(Api.GetMenuList);
};

/**
 *  @description: Create a new menu
 */
export const createMenu = (params: MenuInfoPlain) => {
  return requestClient.post<BaseResp>(Api.CreateMenu, params);
};

/**
 *  @description: Update the menu
 */
export const updateMenu = (params: MenuInfoPlain) => {
  return requestClient.post<BaseResp>(Api.UpdateMenu, params);
};

/**
 *  @description: Delete menus
 */
export const deleteMenu = (params: BaseIDReq) => {
  return requestClient.post<BaseResp>(Api.DeleteMenu, params);
};

/**
 *  @description: Get menu By ID
 */
export const getMenuById = (params: BaseIDReq) => {
  return requestClient.post<BaseDataResp<MenuInfoPlain>>(
    Api.GetMenuById,
    params,
  );
};
