import { connect } from 'react-redux'
import get from 'lodash/get';

import {
  changeSecretSeedItems as onChangeSecretSeedItems,
  setValidStateSecretSeedItem as onSetValidStateSecretSeedItem,
} from '../../actions/secretSeedActions'

const mapStateToProps = (state) => ({
  secretSeed: {
    stepItems: get(state, ['secretSeed', 'stepItems'], {}),
  },
});

const mapDispatchToProps = {
  onChangeSecretSeedItems,
  onSetValidStateSecretSeedItem,
}

export const withSecretSeed = Component => connect(mapStateToProps, mapDispatchToProps)(Component)
