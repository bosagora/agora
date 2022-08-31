import axios from "axios";
import authHeader from "./authHeader";
import { API_URL } from "./serverBase";

const login = (username, password) => {
  return axios
    .post(API_URL + "/login", {
      username,
      password,
    })
    .then((response) => {
      if (response.data) {
        let resData = response.data;
        if (resData.status === 0) sessionStorage.setItem("Authorization", resData.data);
      }
      return response.data;
    });
};

const logout = () => {
  sessionStorage.removeItem("token");
  return axios
    .post(API_URL + "/logout", { headers: authHeader() })
    .then((response) => {
      return;
    });
};

export default {
  login,
  logout,
};
