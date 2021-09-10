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
import React from "react";
import {
  BrowserRouter as Router,
  Route,
  Redirect,
  Switch,
} from "react-router-dom";
import Login from "components/login/login";
import Admin from "components/admin/admin";
import styles from "./app.module.scss";

const App = () => {
  return (
    <div className={styles.application}>
      <div className={styles.container}>
        <Router>
          <Switch>
            <Route
              exact
              path="/"
              render={() => {
                return <Redirect to="/login" />;
              }}
            />
            <Route path="/login" component={Login} />
            <Route path="/admin" component={Admin} />
          </Switch>
        </Router>
      </div>
    </div>
  );
};

export default App;
