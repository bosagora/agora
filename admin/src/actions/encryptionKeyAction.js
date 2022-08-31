import IntegrationService from "../services/integration.service";

export const ENCRYPTION_KEY_REQUIRED = "ENCRYPTION_KEY_REQUIRED";
export const ENCRYPTION_KEY_SUCCESS = "ENCRYPTION_KEY_SUCCESS";
export const ENCRYPTION_KEY_FAILURE = "ENCRYPTION_KEY_FAILURE";
export const ENCRYPTION_AUTH_CLEAR = "ENCRYPTION_AUTH_CLEAR";
export const ENCRYPTION_IS_FETCH = "";

export const generateEncryptionKey = (appName, height) => (dispatch) => {
  dispatch({ type: ENCRYPTION_KEY_REQUIRED });
  return IntegrationService.encryptionKey(appName, height).then(
    (data) => {
      if (data.status === 200) {
        dispatch({
          type: ENCRYPTION_KEY_SUCCESS,
          payload: { ...data },
        });
      } else {
        dispatch({
          type: ENCRYPTION_KEY_FAILURE,
          payload: { ...data },
        });
      }
      return Promise.resolve();
    },
    (error) => {
      const message =
        (error.response &&
          error.response.data &&
          error.response.data.message) ||
        error.message ||
        error.toString();

      dispatch({
        type: ENCRYPTION_KEY_FAILURE,
        payload: message,
      });
      return Promise.reject();
    }
  );
};

export const clearEncryptionKey = () => (dispatch) => {
  dispatch({
    type: ENCRYPTION_AUTH_CLEAR,
  });
};

export const isFetchChange = () => (dispatch) => {
  return {
    type: ENCRYPTION_IS_FETCH,
  };
};
