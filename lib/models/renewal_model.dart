import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RenewalModel {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> requiredDocuments;
  final String estimatedFee;
  final String officialUrl;
  final String status; // e.g. "Expiring Soon", "Valid"

  RenewalModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.requiredDocuments,
    required this.estimatedFee,
    required this.officialUrl,
    required this.status,
  });

  // Mock data for the 4 core renewals
  static List<RenewalModel> getMockData() {
    return [
      RenewalModel(
        id: '1',
        title: 'MyKad (Identity Card)',
        description: 'Renew your identity card for age 18, 25, or replace a lost card.',
        icon: LucideIcons.user,
        color: const Color(0xFFE91E63), // Pink
        requiredDocuments: [
          'Current MyKad (if replacing)',
          'Police Report (if lost/stolen)',
          'Birth Certificate (for age 18 renewal)',
        ],
        estimatedFee: 'RM 10.00 (Standard) - RM 1000.00 (Lost 3rd time)',
        officialUrl: 'https://www.jpn.gov.my/en/core-business/identity-card',
        status: 'Action Required',
      ),
      RenewalModel(
        id: '2',
        title: 'Driving License (CDL)',
        description: 'Renew your Competent Driving License at JPJ or MyEG.',
        icon: LucideIcons.car,
        color: const Color(0xFF2196F3), // Blue
        requiredDocuments: [
          'Original MyKad',
          'Current Driving License',
          '1x Color Photo (White Background)',
        ],
        estimatedFee: 'RM 30.00 per year',
        officialUrl: 'https://public.jpj.gov.my/public/login.htm',
        status: 'Expiring Soon',
      ),
      RenewalModel(
        id: '3',
        title: 'Road Tax (LKM)',
        description: 'Renew your vehicle road tax and ensure insurance is active.',
        icon: LucideIcons.fileText,
        color: const Color(0xFF4CAF50), // Green
        requiredDocuments: [
          'Vehicle Ownership Certificate (VOC/Grant)',
          'Active e-Cover Note (Insurance)',
        ],
        estimatedFee: 'Varies by Engine Capacity (cc)',
        officialUrl: 'https://www.myeg.com.my/services/pdrm',
        status: 'Valid',
      ),
      RenewalModel(
        id: '4',
        title: 'Malaysian Passport (PMA)',
        description: 'Renew your international passport for overseas travel.',
        icon: LucideIcons.plane,
        color: const Color(0xFFFF9800), // Orange
        requiredDocuments: [
          'Original MyKad',
          'Current Passport',
          'Recent Passport Photo (Dark clothes, no glasses)',
        ],
        estimatedFee: 'RM 200.00 (5 Years)',
        officialUrl: 'https://imigresen-online.imi.gov.my/eservices/myPasport',
        status: 'Valid',
      ),
    ];
  }
}
