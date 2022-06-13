import * as React from 'react';
import { FC } from 'react';

import styles from './HelloWorld.module.scss';

import { IHelloWorldProps } from './IHelloWorldProps';
import { useWebPartContext } from '../../../hooks/useWebPartContext';
import { MSGraphClientFactory } from '@microsoft/sp-http';

const HelloWorld: FC<IHelloWorldProps> = (props) => {
  const [name, setName] = React.useState('');
  /*
  * Use cases:
  */

  // get single property
  const webPartId = useWebPartContext(context => context.instanceId);

  // or complex object
  const ctx = useWebPartContext(context => ({
    webPartId: context.instanceId,
    loginName: context.pageContext.user.loginName,
    msGraphClientFactory: context.serviceScope.consume(MSGraphClientFactory.serviceKey)
  }));

  // or just the whole context
  const wpContext = useWebPartContext();

  // get data using ms graph:
  React.useEffect(() => {
    async function process() {
      const client = await ctx.msGraphClientFactory.getClient();
      client
        .api('/me')
        .get((error, user: any, rawResponse?: any) => {
          setName(user.displayName);
        });
    }

    process();
  }, []);

  return (
    <section className={`${styles.helloWorld}`}>
        <div className={styles.welcome}>
          <h3>Welcome to SharePoint Framework (with React Hook [Version: {props.version}])!</h3>
          <div> Legacy page context: <pre>{JSON.stringify(wpContext.pageContext.legacyPageContext)}</pre> </div>
          <div> Web Part id: {webPartId} </div>
          <div> Login name: {ctx.loginName} </div>
          <div> User name: {name} </div>
        </div>
        <div>
          <ul className={styles.links}>
            <li><a href="https://aka.ms/spfx" target="_blank">SharePoint Framework Overview</a></li>
            <li><a href="https://aka.ms/spfx-yeoman-graph" target="_blank">Use Microsoft Graph in your solution</a></li>
            <li><a href="https://aka.ms/spfx-yeoman-teams" target="_blank">Build for Microsoft Teams using SharePoint Framework</a></li>
            <li><a href="https://aka.ms/spfx-yeoman-viva" target="_blank">Build for Microsoft Viva Connections using SharePoint Framework</a></li>
            <li><a href="https://aka.ms/spfx-yeoman-store" target="_blank">Publish SharePoint Framework applications to the marketplace</a></li>
            <li><a href="https://aka.ms/spfx-yeoman-api" target="_blank">SharePoint Framework API reference</a></li>
            <li><a href="https://aka.ms/m365pnp" target="_blank">Microsoft 365 Developer Community</a></li>
          </ul>
        </div>
      </section>
  );
};

export default HelloWorld;
