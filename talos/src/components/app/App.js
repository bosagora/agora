/**
 * The application entry point
 *
 * The application is composed of pages, currently two.
 * A page takes the full viewport and can be hidden or shown.
 *
 * The first page is "intro" which is simply a welcoming screen.
 *
 * The second page ("config") allows configuring the node options.
 * Since there are many configuration options, the second page
 * is actually divided into multiple steps, each step allowing
 * To configure one aspect of the node.
 *
 * At the end of the configuration step, a request is sent to Agora,
 * containing the configuration to write out to disk.
 *
 * The intro page lives in components/intro, while the config page
 * lives in components/config.
 * Each directory under 'components/config/steps/', represent a single
 * configuration step. The steps are named after the section they represent:
 * e.g. the 'banman' section in 'config.yaml' is in
 * 'components/config/steps/banman/'.
 *
 * Each component is split into two main parts: the wrapper (Wrapper.js),
 * and the content (Content.js). They come with their associated SCSS modules.
 * The wrapper simply exposes a 'Step' class, e.g. 'BanmanStep',
 * while the content exposes 'BanmanContent'.
 *
 * Additionally, multiple components are available under 'components/items'.
 * Those are general purpose, and not specific to any step.
 * Finally, certain page-specific components live under their respective page directory.
 */
import React from 'react';

import Intro from "components/intro/intro"
import ConfigPage from "components/config/Wrapper"

import './app.scss'

const App = () => {
    return (
        <div>
            <Intro navigationIndex={0} />
            <ConfigPage navigationIndex={1} />
        </div>
    )
}

export default App;
