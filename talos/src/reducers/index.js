import { combineReducers } from 'redux'

// import { reducer as notifReducer } from 'redux-notifications'

import appStateReducer from './appStateReducer'
import secretSeedReducer from './secretSeedReducer'
import networkOptionsReducer from './networkOptionsReducer'
import banManagementReducer from './banManagementReducer'
import administrativeInterfaceReducer from './administrativeInterfaceReducer'

const reducers = combineReducers({
  // notif: notifReducer,

  secretSeed: secretSeedReducer,
  networkOptions: networkOptionsReducer,
  banManagement: banManagementReducer,
  administrativeInterface: administrativeInterfaceReducer,
  appState: appStateReducer,
})

export default reducers
