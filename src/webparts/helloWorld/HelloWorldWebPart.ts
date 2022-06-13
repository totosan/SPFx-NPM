import * as React from 'react';
import * as ReactDom from 'react-dom';
import { BaseClientSideWebPart } from '@microsoft/sp-webpart-base';


import HelloWorld from './components/HelloWorld';
import AppContext from '../../common/AppContext';

export interface IHelloWorldWebPartProps {
  description: string;
}

export default class HelloWorldWebPart extends BaseClientSideWebPart<IHelloWorldWebPartProps> {

  public render(): void {
    const element: React.ReactElement = React.createElement(
      AppContext.Provider,
      {
        value: this.context
      },
      React.createElement(HelloWorld, { 
        description: this.properties.description,
        version: this.manifest.version
      })
    );

    ReactDom.render(element, this.domElement);
  }

  protected onDispose(): void {
    ReactDom.unmountComponentAtNode(this.domElement);
  }
}
