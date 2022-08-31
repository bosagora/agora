export default function authHeader() {
  const token = sessionStorage.getItem("Authorization");
  if (token) {
    return {
      "Authorization": token,
    };
  } else {
    return {};
  }
}
