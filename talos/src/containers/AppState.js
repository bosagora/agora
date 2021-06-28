import { connect } from 'react-redux'
import get from 'lodash/get';

import {
  openAppOrder as onOpenAppOrder,
  closeAppOrder as onCloseAppOrder,
  request as onRequest,
  requestBegin as onRequestBegin,
  REQUEST
} from '../actions/appStateActions'

const mapStateToProps = (state) => ({
  isOrderOn: get(state, ['appState', 'isOrderOn'], false),
  requestState: get(state, ['appState', 'requestState'], REQUEST.BEGIN),
  requestResult: get(state, ['appState', 'requestResult'], ""),
});

const mapDispatchToProps = {
  onOpenAppOrder,
  onCloseAppOrder,
  onRequest,
  onRequestBegin,
}

export const withAppState = Component => connect(mapStateToProps, mapDispatchToProps)(Component)
