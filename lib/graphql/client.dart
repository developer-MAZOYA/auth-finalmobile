// import 'package:graphql_flutter/graphql_flutter.dart';
// import 'package:flutter/material.dart';

// class GraphQLConfig {
//   static String get graphqlEndpoint {
//     // For development - use your computer's IP
//     return 'http://192.168.1.100:8080/graphql'; // Replace with your IP
//     // For production: return 'https://your-domain.com/graphql';
//   }

//   static HttpLink httpLink = HttpLink(GraphQLConfig.graphqlEndpoint);

//   static GraphQLClient getClient() {
//     return GraphQLClient(
//       link: httpLink,
//       cache: GraphQLCache(),
//     );
//   }

//   static ValueNotifier<GraphQLClient> initializeClient() {
//     ValueNotifier<GraphQLClient> client = ValueNotifier(
//       GraphQLClient(
//         link: httpLink,
//         cache: GraphQLCache(),
//       ),
//     );
//     return client;
//   }
// }
