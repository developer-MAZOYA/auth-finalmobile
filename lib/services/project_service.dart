import 'package:graphql_flutter/graphql_flutter.dart';

class ProjectService {
  final GraphQLClient client;

  ProjectService(this.client);

  // Get all projects
  Future<QueryResult> getAllProjects() async {
    const String query = """
      query GetAllProjects {
        getAllProjects {
          id
          name
          description
          region
          council
          startDate
          endDate
          createdAt
          observationCount
          hasObservations
          observations
        }
      }
    """;

    return await client.query(QueryOptions(document: gql(query)));
  }

  // Create project
  Future<QueryResult> createProject(Map<String, dynamic> projectData) async {
    const String mutation = """
      mutation CreateProject(\$project: ProjectInput!) {
        createProject(project: \$project) {
          id
          name
          description
          region
          council
          observationCount
        }
      }
    """;

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: {
        'project': projectData,
      },
    );

    return await client.mutate(options);
  }

  // Add observation to project
  Future<QueryResult> addObservation(
      String projectId, String observation) async {
    const String mutation = """
      mutation AddObservation(\$projectId: ID!, \$observation: String!) {
        addObservation(projectId: \$projectId, observation: \$observation) {
          id
          name
          observations
          observationCount
        }
      }
    """;

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: {
        'projectId': projectId,
        'observation': observation,
      },
    );

    return await client.mutate(options);
  }
}
