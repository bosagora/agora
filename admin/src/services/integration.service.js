import axios from "axios";
import authHeader from "./authHeader";
import { API_URL } from "./serverBase";

const validatorAuth = () => {
  return axios.post(API_URL + "/admin/validator", {},{
    headers: authHeader(),
  });
};

const encryptionKey = (appName, height) => {
  return axios.post(
    API_URL + "/admin/encryptionkey",
    {
      app: appName,
      height: height,
    },
    {
      headers: authHeader(),
    }
  );
};

export default {
  validatorAuth,
  encryptionKey,
};
