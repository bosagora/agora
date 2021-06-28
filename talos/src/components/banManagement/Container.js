import { connect } from 'react-redux'
import get from 'lodash/get';

import {
  changeBanManagementItems as onChangeBanManagementItems,
} from './Action'

const mapStateToProps = (state) => ({
  banManagement: {
    stepItems: get(state, ['banManagement', 'stepItems'], {}),
  },
});

const mapDispatchToProps = {
  onChangeBanManagementItems,
}

export const withBanManagement = Component => connect(mapStateToProps, mapDispatchToProps)(Component)
