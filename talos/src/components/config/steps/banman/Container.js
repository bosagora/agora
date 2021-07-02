import { connect } from 'react-redux'
import get from 'lodash/get';

import {
  changeBanmanItems as onChangeBanmanItems,
} from './Action'

const mapStateToProps = (state) => ({
  banman: {
    stepItems: get(state, ['banman', 'stepItems'], {}),
  },
});

const mapDispatchToProps = {
  onChangeBanmanItems,
}

export const withBanman = Component => connect(mapStateToProps, mapDispatchToProps)(Component)
