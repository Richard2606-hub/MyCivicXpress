class UniversityCourse {
  final String id;
  final String name;
  final String university;
  final String type; // Public (IPTA) or Private (IPTS)
  final String level; // Diploma, Degree
  final double estimatedFee; // Total estimated fee
  final int durationYears;
  final String websiteUrl;

  UniversityCourse({
    required this.id,
    required this.name,
    required this.university,
    required this.type,
    required this.level,
    required this.estimatedFee,
    required this.durationYears,
    required this.websiteUrl,
  });

  static List<UniversityCourse> getMockCourses() {
    return [
      UniversityCourse(
        id: '1',
        name: 'Bachelor of Computer Science',
        university: 'Universiti Malaya (UM)',
        type: 'Public',
        level: 'Degree',
        estimatedFee: 12000,
        durationYears: 4,
        websiteUrl: 'https://www.um.edu.my',
      ),
      UniversityCourse(
        id: '2',
        name: 'Bachelor of Software Engineering',
        university: 'Taylor\'s University',
        type: 'Private',
        level: 'Degree',
        estimatedFee: 95000,
        durationYears: 3,
        websiteUrl: 'https://university.taylors.edu.my',
      ),
      UniversityCourse(
        id: '3',
        name: 'Diploma in Information Technology',
        university: 'Sunway University',
        type: 'Private',
        level: 'Diploma',
        estimatedFee: 45000,
        durationYears: 2,
        websiteUrl: 'https://sunwayuniversity.edu.my',
      ),
      UniversityCourse(
        id: '4',
        name: 'Bachelor of Accounting',
        university: 'Universiti Sains Malaysia (USM)',
        type: 'Public',
        level: 'Degree',
        estimatedFee: 10500,
        durationYears: 4,
        websiteUrl: 'https://www.usm.my',
      ),
      UniversityCourse(
        id: '5',
        name: 'Bachelor of Medicine and Surgery (MBBS)',
        university: 'Monash University Malaysia',
        type: 'Private',
        level: 'Degree',
        estimatedFee: 550000,
        durationYears: 5,
        websiteUrl: 'https://www.monash.edu.my',
      ),
      UniversityCourse(
        id: '6',
        name: 'Diploma in Business Administration',
        university: 'UiTM',
        type: 'Public',
        level: 'Diploma',
        estimatedFee: 4500,
        durationYears: 3,
        websiteUrl: 'https://www.uitm.edu.my',
      ),
    ];
  }
}

class PtptnLogic {
  // Calculates the estimated yearly loan amount
  static double calculateLoan({
    required String incomeTier, // B40, M40, T20
    required String institutionType, // Public, Private
    required String levelOfStudy, // Diploma, Degree
  }) {
    // Base maximum loans per year (Approximate PTPTN guidelines)
    double baseAmount = 0;

    if (institutionType == 'Public') {
      if (levelOfStudy == 'Diploma') {
        baseAmount = 4750;
      } else if (levelOfStudy == 'Degree') {
        baseAmount = 6500;
      }
    } else if (institutionType == 'Private') {
      if (levelOfStudy == 'Diploma') {
        baseAmount = 6800;
      } else if (levelOfStudy == 'Degree') {
        baseAmount = 13600;
      }
    }

    // Apply Tier Multiplier
    if (incomeTier == 'B40') {
      return baseAmount; // Maximum
    } else if (incomeTier == 'M40') {
      return baseAmount * 0.75; // 75% of max
    } else if (incomeTier == 'T20') {
      return baseAmount * 0.50; // 50% of max
    }

    return 0;
  }
}
