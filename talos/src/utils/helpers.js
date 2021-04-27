export const createActionTypesOf = actionName => ({
  REQUEST: `${actionName}_REQUEST`,
  SUCCESS: `${actionName}_SUCCESS`,
  ERROR: `${actionName}_ERROR`,
  STATUS: `${actionName}_STATUS`,
  BEGIN: `${actionName}_BEGIN`,
  END: `${actionName}_END`,
});

export const createReducer = (initialState, reducerMap) => {
	return function(state = initialState, action) {
		const reducer = reducerMap[action.type];

		return reducer ? reducer(state, action) : state;
	};
};
