import { connect } from 'react-redux'
import get from 'lodash/get';

import {
  toStep as onToStep,
  toNextStep as onToNextStep,
  toPrevStep as onToPrevStep,
  request as onRequest,
  requestBegin as onRequestBegin,
  REQUEST
} from './AppAction'

const mapStateToProps = (state) => ({
  currentIndex: get(state, ["appState", "currentIndex"], 0),
  prevIndex: get(state, ["appState", "prevIndex"], 0),
  requestState: get(state, ['appState', 'requestState'], REQUEST.BEGIN),
  requestResult: get(state, ['appState', 'requestResult'], ""),
});

const mapDispatchToProps = {
  onToStep,
  onToNextStep,
  onToPrevStep,
  onRequest,
  onRequestBegin,
}

export const withAppState = Component => connect(mapStateToProps, mapDispatchToProps)(Component)
