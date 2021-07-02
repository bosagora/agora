import { combineReducers } from 'redux'

import appStateReducer from './Reducer'
import validatorReducer from 'components/config/steps/validator/Reducer'
import networkReducer from 'components/config/steps/network/Reducer'
import banmanReducer from 'components/config/steps//banman/Reducer'
import adminReducer from 'components/config/steps/admin/Reducer'

const reducers = combineReducers({
  validator: validatorReducer,
  network: networkReducer,
  banman: banmanReducer,
  admin: adminReducer,
  appState: appStateReducer,
})

export default reducers;
