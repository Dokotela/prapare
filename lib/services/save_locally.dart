import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:fhir/r4.dart';
import 'package:get_storage/get_storage.dart';

import 'db_interface.dart';

Future saveLocally() async {
  var bundle = Bundle(
    type: BundleType.transaction,
    entry: [],
  );

  final responses = await DbInterface()
      .returnListOfSingleResourceType('QuestionnaireResponse');

  bundle = addToBundle(responses, bundle);

  final conditions =
      await DbInterface().returnListOfSingleResourceType('Condition');

  bundle = addToBundle(conditions, bundle);

  final observations =
      await DbInterface().returnListOfSingleResourceType('Observation');

  bundle = addToBundle(observations, bundle);

  final path = (await getExternalStorageDirectory()).path;
  final file = File('$path/bundle.txt');
  final saveBundle = bundle.toYaml();
  file.writeAsString(saveBundle);
}

Bundle addToBundle(
    Either<DbFailure, List<Resource>> dbResources, Bundle bundle) {
  dbResources.fold(
    (l) => print('Error: ${l.errorMessage}'),
    (r) {
      for (var res in r) {
        bundle.entry.add(BundleEntry(
            resource: res,
            request: BundleRequest(
                method: BundleRequestMethod.post,
                url: FhirUri(res.resourceType))));
      }
    },
  );
  return bundle;
}
