import { connect } from 'react-redux'
import get from 'lodash/get';

import {
  changeNetworkItems as onChangeNetworkItems,
} from './Action'

const mapStateToProps = (state) => ({
  network: {
    stepItems: get(state, ['network', 'stepItems'], {}),
  },
});

const mapDispatchToProps = {
  onChangeNetworkItems,
}

export const withNetwork = Component => connect(mapStateToProps, mapDispatchToProps)(Component)
