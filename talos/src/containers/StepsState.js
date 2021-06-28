import { connect } from 'react-redux'
import get from 'lodash/get';

import {
  toStep as onToStep,
  toNextStep as onToNextStep,
  toPrevStep as onToPrevStep,
} from '../actions/stepsStateActions'

const mapStateToProps = (state) => ({
  currentIndex: get(state, ["stepsState", "currentIndex"], 0),
  prevIndex: get(state, ["stepsState", "prevIndex"], 0),
});

const mapDispatchToProps = {
  onToStep,
  onToNextStep,
  onToPrevStep,
}

export const withStepsState = Component => connect(mapStateToProps, mapDispatchToProps)(Component)
