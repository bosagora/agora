import { connect } from 'react-redux'
import get from 'lodash/get';

import {
  changeNetworkOptionsItems as onChangeNetworkOptionsItems,
} from './Action'

const mapStateToProps = (state) => ({
  networkOptions: {
    stepItems: get(state, ['networkOptions', 'stepItems'], {}),
  },
});

const mapDispatchToProps = {
  onChangeNetworkOptionsItems,
}

export const withNetworkOptions = Component => connect(mapStateToProps, mapDispatchToProps)(Component)
