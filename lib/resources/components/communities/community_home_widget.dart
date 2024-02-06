import 'dart:developer';
import 'package:com.example.while_app/resources/components/communities/community_user_card.dart';
import 'package:com.example.while_app/resources/components/message/models/community_user.dart';
import 'package:com.example.while_app/view_model/providers/auth_provider.dart';
import 'package:com.example.while_app/view_model/providers/connect_community_provider.dart';
import 'package:com.example.while_app/view_model/providers/connect_users_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommunityHomeWidget extends ConsumerWidget {
  const CommunityHomeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allCommunityAsyncValue = ref.watch(allCommunitiesProvider);
    final myCommunityAsyncValue = ref.watch(myCommunityUidsProvider);
    var toogleSearch = ref.watch(toggleSearchStateProvider);
    final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
    return Scaffold(
      backgroundColor: Colors.black,
      body: allCommunityAsyncValue.when(
        data: (allCommunities) => myCommunityAsyncValue.when(
          data: (joinedCommunity) {
            final notJoinedCommunity = joinedCommunity
                .map((communityId) => allCommunities.firstWhere(
                      (community) => community.id == communityId,
                      orElse: () => Community
                          .empty(), // Provide a fallback value to avoid the error
                    ))
                .toList();
            var communityList = toogleSearch == 3
                ? notJoinedCommunity
                    .where(
                        (user) => user.name.toLowerCase().contains(searchQuery))
                    .toList()
                : notJoinedCommunity;

            log(communityList.length.toString());
            log('usersList.length.toString()');
            if (communityList.isEmpty) {
              return const Center(
                child: Text(
                  'No Data Found',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }
            return ListView.builder(
              itemCount: communityList.length,
              itemBuilder: (context, index) {
                return ChatCommunityCard(user: communityList[index]);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
