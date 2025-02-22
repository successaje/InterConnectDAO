// import { AuthClient } from "@dfinity/auth-client";

import { AuthClient } from "../../../node_modules/@dfinity/auth-client";

import React, { createContext, useContext, useEffect, useState} from "react";

const AuthContext = createContext();


const defaultOptions = {
    /**
     *  @type {import("@dfinity/auth-client").AuthClientCreateOptions}
     */
    createOptions: {
      idleOptions: {
        // Set to true if you do not want idle functionality
        disableIdle: true,
      },
    },
    /**
     * @type {import("@dfinity/auth-client").AuthClientLoginOptions}
     */
    loginOptions: {
      identityProvider:
        process.env.DFX_NETWORK === "ic"
          ? "https://identity.ic0.app/#authorize"
          : `http://localhost:4943?canisterId=rdmx6-jaaaa-aaaaa-aaadq-cai#authorize`,
    },
};

/**
 *
 * @param options - Options for the AuthClient
 * @param {AuthClientCreateOptions} options.createOptions - Options for the AuthClient.create() method
 * @param {AuthClientLoginOptions} options.loginOptions - Options for the AuthClient.login() method
 * @returns
 */

export const useAuthClient = (options = defaultOptions) => {

    const [isAuthenticated, setIsAuthenticated] = useState(false);
    const [authClient, setAuthClient] = useState(null);
    const [identity, setIdentity] = useState(null);
    const [principal, setPrincipal] = useState(null);
    const [whoami, setWhoami] = useState(null);

    useEffect(() => {

        AuthClient.create(options.createOptions).then(async (client) => {
            updateClient(client);
        });
    }, []);
    
    const login = () => {
        authClient.login({
            ...options.loginOptions,
            onSuccess: () => {
                updateClient(authClient)
            },
        });
    };

    async function updateClient(client){
        const isAuthenticated = await client.isAuthenticated();
        setIsAuthenticated(isAuthenticated);

        const principal = identity.getPrincipal();
        setPrincipal(pricipal);

        const identity = client.getIdentity();
        setIdentity(identity);

        setAuthClient(client);

        const actor = createActor(canisterId, {
            agentOptions: {
                identity,
            },
        });

        setWhoami(actor);
    }

    async function logout() {
        await authClient?.logout();
        await updateClient(authClient);
    }


    return {
        isAuthenticated,
        login,
        logout,
        authClient,
        identity,
        principal,
        whoami,
    };

};

/**
 * @type {React.FC}
 */

export const AuthProvider = ({ children }) => {
    const auth = useAuthClient();

    return <AuthContext.Provider value={auth}>{ children }</AuthContext.Provider>;
};

export const useAuth = () => useContext(AuthContext);