///
/// Code generated by jsonToDartModel https://ashamp.github.io/jsonToDartModel/
///
class UserLoginResponseUser {
  /*
{
  "userId": "41610f45-bb19-4192-b8b8-05ed1edb61a1",
  "firstName": "Girish",
  "lastName": "Parate",
  "email": "parategirish50@gmail.com",
  "createdAt": "2025-03-16T13:59:57.621Z",
  "updatedAt": "2025-03-16T13:59:57.653Z",
  "deletedAt": "2025-03-16T13:59:57.653Z"
} 
*/

  String? userId;
  String? firstName;
  String? lastName;
  String? email;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;

  UserLoginResponseUser({
    this.userId,
    this.firstName,
    this.lastName,
    this.email,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });
  UserLoginResponseUser.fromJson(Map<String, dynamic> json) {
    userId = json['userId']?.toString();
    firstName = json['firstName']?.toString();
    lastName = json['lastName']?.toString();
    email = json['email']?.toString();
    createdAt = json['createdAt']?.toString();
    updatedAt = json['updatedAt']?.toString();
    deletedAt = json['deletedAt']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['userId'] = userId;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['email'] = email;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['deletedAt'] = deletedAt;
    return data;
  }
}

class UserLoginResponse {
  /*
{
  "user": {
    "userId": "41610f45-bb19-4192-b8b8-05ed1edb61a1",
    "firstName": "Girish",
    "lastName": "Parate",
    "email": "parategirish50@gmail.com",
    "createdAt": "2025-03-16T13:59:57.621Z",
    "updatedAt": "2025-03-16T13:59:57.653Z",
    "deletedAt": "2025-03-16T13:59:57.653Z"
  },
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiI0MTYxMGY0NS1iYjE5LTQxOTItYjhiOC0wNWVkMWVkYjYxYTEiLCJpYXQiOjE3NDI1Mjg1NTEsImV4cCI6MTc0MjUzMjE1MSwiaXNzIjoiZ2lyaXNoLmNvbSJ9.pGqlKEo0YKndnhUt83XGYnV794azraShNyUYRzNGRiY",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE3NDI1Mjg1NTEsImV4cCI6MTc0MjUzMjE1MSwiYXVkIjoiNDE2MTBmNDUtYmIxOS00MTkyLWI4YjgtMDVlZDFlZGI2MWExIiwiaXNzIjoiZ2lyaXNoLmNvbSJ9.BS2QU3P-EHqwB0UMUPmNFK6E9NsA3oH5Nn1fysM1pBc"
} 
*/

  UserLoginResponseUser? user;
  String? accessToken;
  String? refreshToken;

  UserLoginResponse({this.user, this.accessToken, this.refreshToken});
  UserLoginResponse.fromJson(Map<String, dynamic> json) {
    user =
        (json['user'] != null)
            ? UserLoginResponseUser.fromJson(json['user'])
            : null;
    accessToken = json['accessToken']?.toString();
    refreshToken = json['refreshToken']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (user != null) {
      data['user'] = user!.toJson();
    }
    data['accessToken'] = accessToken;
    data['refreshToken'] = refreshToken;
    return data;
  }
}

///
/// Code generated by jsonToDartModel https://ashamp.github.io/jsonToDartModel/
///
class ApiErrorResponseError {
  /*
{
  "status": 502,
  "message": "Email Or Password is wrong"
} 
*/

  int? status;
  String? message;

  ApiErrorResponseError({this.status, this.message});
  ApiErrorResponseError.fromJson(Map<String, dynamic> json) {
    status = json['status']?.toInt();
    message = json['message']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    return data;
  }
}

class ApiErrorResponse {
  /*
{
  "error": {
    "status": 502,
    "message": "Email Or Password is wrong"
  }
} 
*/

  ApiErrorResponseError? error;

  ApiErrorResponse({this.error});
  ApiErrorResponse.fromJson(Map<String, dynamic> json) {
    error =
        (json['error'] != null)
            ? ApiErrorResponseError.fromJson(json['error'])
            : null;
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (error != null) {
      data['error'] = error!.toJson();
    }
    return data;
  }
}
