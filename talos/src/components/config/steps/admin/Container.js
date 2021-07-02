import { connect } from 'react-redux'
import get from 'lodash/get';

import {
  changeAdminItems as onChangeAdminItems,
  setValidAdminItem as onSetValidAdminItem,
} from './Action'

const mapStateToProps = (state) => ({
  admin: {
    stepItems: get(state, ['admin', 'stepItems'], {}),
  },
});

const mapDispatchToProps = {
  onChangeAdminItems,
  onSetValidAdminItem,
}

export const withAdmin = Component => connect(mapStateToProps, mapDispatchToProps)(Component)
