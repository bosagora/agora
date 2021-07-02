import { connect } from 'react-redux'
import get from 'lodash/get';

import {
  changeValidatorItems as onChangeValidatorItems,
  setValidStateValidatorItem as onSetValidStateValidatorItem,
} from './Action'

const mapStateToProps = (state) => ({
  validator: {
    stepItems: get(state, ['validator', 'stepItems'], {}),
  },
});

const mapDispatchToProps = {
  onChangeValidatorItems,
  onSetValidStateValidatorItem,
}

export const withValidator = Component => connect(mapStateToProps, mapDispatchToProps)(Component)
