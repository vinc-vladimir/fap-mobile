final emailRegex = RegExp(
  r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?|)+\.[a-zA-Z]{2,}$",
);

final passwordRegex = RegExp(
  r'^(?=.*\d)(?=.*[A-Z])(?=.*[a-z])(?=.*[^\w\s:])(\S){8,}$',
);
