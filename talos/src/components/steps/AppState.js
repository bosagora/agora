import { connect } from 'react-redux'
import get from 'lodash/get';

import {
  toStep as onToStep,
  toNextStep as onToNextStep,
  toPrevStep as onToPrevStep,
  openAppOrder as onOpenAppOrder,
  closeAppOrder as onCloseAppOrder,
  request as onRequest,
  requestBegin as onRequestBegin,
  REQUEST
} from './AppAction'

const mapStateToProps = (state) => ({
  isOrderOn: get(state, ['appState', 'isOrderOn'], false),
  currentIndex: get(state, ["appState", "currentIndex"], 0),
  prevIndex: get(state, ["appState", "prevIndex"], 0),
  requestState: get(state, ['appState', 'requestState'], REQUEST.BEGIN),
  requestResult: get(state, ['appState', 'requestResult'], ""),
});

const mapDispatchToProps = {
  onToStep,
  onToNextStep,
  onToPrevStep,
  onOpenAppOrder,
  onCloseAppOrder,
  onRequest,
  onRequestBegin,
}

export const withAppState = Component => connect(mapStateToProps, mapDispatchToProps)(Component)
