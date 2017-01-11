// User actions related to authentication
export const LOGGED_IN = 'LOGGED_IN';
export const LOGGING_IN = 'LOGGING_IN';
export const LOGGED_OUT = 'LOGGED_OUT';

export function userLoggedIn(userInfo) {
	return {
		type: LOGGED_IN,
		data: userInfo,
	};
}

export function userLoggingIn() {
	return {
		type: LOGGING_IN
	};
}

export function userLoggedOut() {
	return {
		type: LOGGED_OUT,
	};
}
