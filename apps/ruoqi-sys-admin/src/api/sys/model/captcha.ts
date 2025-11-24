export interface CaptchaResp {
  captchaToken: string;
  captchaImage: string;
}

export interface GetEmailCaptchaReq {
  email: string;
}

export interface GetSmsCaptchaReq {
  phoneNumber: string;
}
