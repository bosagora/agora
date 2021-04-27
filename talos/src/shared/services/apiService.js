import axios from 'axios';
import config from './apiConfig'

var axiosResult = axios.create({
  withCredentials: true,
  crossDomain: true,
  baseURL: config.get("baseURL"),
});

export default axiosResult;
